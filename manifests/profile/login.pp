# nebula::profile::login
#
# Profile for login server.
#
# @example
#   include nebula::profile::login
class nebula::profile::login (
  Array[String] $groups = [],
) {
  include nebula::profile::interactive
  include nebula::profile::taghosts::index
  @nebula::taghosts::tag { 'login': }
  include nebula::profile::okta
  include nebula::profile::krb5
  include nebula::profile::users
  $groups.each |$group| {
    nebula::usergroup { $group: }
  }
}
