# Class: collectd::plugin::mongodb
#
class collectd::plugin::mongodb {
  $mongod_bind_ip = hiera('mongod_bind_ip','127.0.0.1')
  $mongod_dbs     = hiera('mongod_dbs',['admin'])

  if !defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
    }
  }

  if !defined(Package['pymongo']) {
    package { 'pymongo':
      ensure   => 'present',
      provider => 'pip',
      require  => Package['python-pip'],
    }
  }

  file { '/usr/local/collectd-plugins/mongodb.py':
    ensure  => 'file',
    content => template('collectd/mongodb.py.erb'),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
  }

  file_line { 'mongoline':
    ensure => present,
    line   => 'replication             value:GAUGE:U:U',
    match  => '^replication\s+',
    path   => '/usr/share/collectd/types.db',
  }

  file { '/etc/collectd.d/mongodb.conf':
    ensure  => 'file',
    content => template('collectd/mongodb.conf.erb'),
    group   => '0',
    mode    => '0644',
    notify  => Service['collectd'],
    owner   => '0',
    require => [
      Package['pymongo'],
      File['/usr/local/collectd-plugins/mongodb.py'],
      File_line['mongoline']
    ],
  }
}
