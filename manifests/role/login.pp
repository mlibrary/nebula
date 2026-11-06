class nebula::role::login {
  include nebula::role::minimum

  include nebula::profile::interactive
  include nebula::profile::taghosts::index
  @nebula::taghosts::tag { 'login': }

  include nebula::profile::okta
  include nebula::profile::krb5
  include nebula::profile::networking
}
