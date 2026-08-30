class nebula::role::proxmox (
) {
  include nebula::profile::authorized_keys
  include nebula::profile::root
  include nebula::profile::vim
  include nebula::profile::ntp
  include nebula::profile::taghosts::tags

  include proxmox
}
