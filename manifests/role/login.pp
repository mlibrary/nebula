# nebula::profile::login
#
# Role for login server.
#
# @example
#   include nebula::role::login
class nebula::role::login {
  include nebula::role::minimum
  include nebula::profile::login
  include nebula::profile::networking
}
