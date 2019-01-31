# -----------------------------------------------------------------------------
# Author  = Kunal Mehta
# Date    = 2019/01/30
# Version = 1.0 'filebeat/install.pp'
# Purpose = This is the
#           'filebeat/install' profile.
#
# -----------------------------------------------------------------------------

class profile::devops::filebeat::install (
  $config = undef,
) {

  $nexus_server  = hiera('profile::common::nexus')
  $nexus_repo    = hiera('profile::devops::filebeat::install::nexus_repo')
  $filebeat_package = hiera('profile::devops::filebeat::install::package')
  $download_dir  = hiera('profile::devops::filebeat::install::download_dir')
  $filebeat_dir     = hiera('profile::devops::filebeat::install::filebeat_dir')

  # Determine filebeat version to be installed (V.R.M.F).
  $vrmf = "$filebeat_package".match(/[0-9]+[\.]+[0-9]+[\-]+[0-9]+[\.]+[0-9]+[\.]+[0-9]+/)
  $filebeat_version = $vrmf[0]

  # Set the global execution path.
  Exec { path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'] }
  # Get configuration details.

  exec { 'get_filebeat':
    cwd         => "${download_dir}",
    command     => "wget ${nexus_server}/${nexus_repo}/${filebeat_package} && touch ${download_dir}/.puppet/get_filebeat.done",
    unless      => "test -e ${download_dir}/${filebeat_package}",
    timeout     => 12000,
    creates     => "${download_dir}/.puppet/get_filebeat.done"
  } ->
  exec { 'unzip_filebeat':
     cwd         => "${download_dir}",
     command     => "rpm -ivh ${filebeat_package} && touch ${download_dir}/.puppet/unzip_filebeat.done",
     timeout     => 1200,
     creates     => "${download_dir}/.puppet/unzip_filebeat.done",
   } ->
   exec { 'mv_filebeat_home_dir':
    cwd         => "${download_dir}",
    command     => "mv /usr/share/filebeat/* /app/filebeat/ && touch ${download_dir}/.puppet/mv_filebeat_home_dir.done",
    timeout     => 1200,
    creates     => "${download_dir}/.puppet/mv_filebeat.done",
   } ->
   exec { 'rm_filebeat_package':
     cwd        => "${download_dir}",
     command    => "rm -rf ${filebeat_package} && touch ${download_dir}/.puppet/rm_filebeat_package.done",
     timeout    => 1200,
     creates    => "${download_dir}/.puppet/rm_filebeat_package.done"
   }
   exec { 'change_ownership':
    cwd         => "${filebeat_home_dir}",
    command     => "chown -R filebeat:filebeat ${filebeat_home_dir}  && touch ${download_dir}/.puppet/change_filebeat_ownership.done",
    creates     => "${download_dir}/.puppet/change_filebeat_ownership.done",
   }
}

# -----------------------------------------------------------------------------
# End of file.
# -----------------------------------------------------------------------------
