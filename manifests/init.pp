# Class: mysql
#
#   This class installs mysql client software.
#
# Parameters:
#   [*client_package_name*]  - The name of the mysql client package.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql (
  $package_name   = $mysql::params::client_package_name,
  $package_ensure = 'present'
) inherits mysql::params {

  include sqlramdisk

  package { 'mysql_client':
    ensure => $package_ensure,
    name   => $package_name,
  }
# enable phpmyadmin
  file { "/etc/apache2/conf.d/phpmyadmin.conf":
        notify => Service["apache2"],
        ensure => "link",
        target => "../../phpmyadmin/apache.conf",
        owner => "root",
        group => "root",
        mode => 644,
        require => [Package["apache2"], Package["drupalbuntu-lamp-config"]],
    }

}

class sqlramdisk ()
  {
    file { "/tmp/sqlramdisk":
      owner => root,
      group => root,
      mode => '0777',
      source => "puppet:///modules/mysql/sqlramdisk"
    }
    file { "/tmp/dellog":
      owner => root,
      group => root,
      mode => '0777',
      source => "puppet:///modules/mysql/dellog"
    }

    #exec { "/tmp/sqlramdisk" :
    #    creates => "/var/lib/.mysql/ibdata1",
    #    require => [File[ "/tmp/sqlramdisk"], Package["mysql-server"], Exec [ "/tmp/dellog"] ],
    #}
    #exec { "/tmp/dellog":
    #  require => [File["/tmp/dellog"]],
    #}
}

class sqlcron ()
  {
    cron { sqlsync:
      command => "rsync -a --delete /var/lib/mysql/ /var/lib/.mysql; touch /temp/sqlsync",
      user => root,
      minute => '*/1',
      require => [File["/etc/init/mysql.conf"]], 
    }  
}
