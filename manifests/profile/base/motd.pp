# nebula::profile::base::motd
#
# configure motd
#
# @example
#   include nebula::profile::base::motd
class nebula::profile::base::motd (
  String  $contact_email,
  String  $sysadmin_dept,
) {
  if $facts['os']['family'] == 'Debian' {
    file { '/etc/motd':
      content => template('nebula/profile/base/motd.erb'),
    }

    if($::operatingsystem == 'Ubuntu') {
      # delete a lot of useless motd content so it's not a half page long
      file { '/etc/update-motd.d/10-help-text': ensure => absent }
      file { '/etc/update-motd.d/50-motd-news': ensure => absent }
      file { '/etc/update-motd.d/90-updates-available': ensure => absent }
      file { '/etc/update-motd.d/97-overlayroot': ensure => absent }
      file { '/var/lib/update-notifier/hide-esm-in-motd': content => '# managed by puppet' }
    }
  }
}
