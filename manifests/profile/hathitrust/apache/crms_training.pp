# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::crms_training
#
# crms-training.babel.hathitrust.org virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::crms_training
class nebula::profile::hathitrust::apache::crms_training (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
) {

  ## VHOST DEFINITION

  $servername = "crms-training.${prefix}babel.${domain}"

  $imgsrv_address = lookup('nebula::profile::hathitrust::imgsrv::bind');

  file { "/var/log/apache2/crms-training":
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  apache::vhost { "${servername} ssl":
    servername            => $servername,
    use_canonical_name    => 'On',
    port                  => '443',
    docroot               => $sdrroot,
    manage_docroot        => false,
    error_log_file        => 'crms-training/error.log',
    access_log_file       => 'crms-training/access.log',
    access_log_format     => 'combined',
    *                     => $ssl_params,

    # from babel-common

    aliases               => [
      {
        aliasmatch => '^/robots.txt$',
        path       => "${sdrroot}/common/web/robots.txt"
      },
      {
        aliasmatch => '^/favicon.ico$',
        path       => "${sdrroot}/common/web/favicon.ico"
      },
      {
        # Used for example logo and style sheet in error templates.
        alias => '/shibboleth-sp/main.css',
        path  => '/usr/share/shibboleth/main.css'
      }
    ],

    directoryindex        => 'index.html',

    setenv                => [
      "SDRROOT ${sdrroot}",
      'SDRDATAROOT /sdr1',
      'CRMS_INSTANCE crms-training',
    ],

    rewrites              => [
      {
        # Map web content URLs to the web directories within each application repository,
        # if the file being requested exists.
        #
        # URLs are of the form /app/foobar and are mapped to /app/web/foobar.
        #
        # 2010-10-01 skorner
        # it also supports a comment => '' field; not sure if we want to use that
        rewrite_cond => ['%{DOCUMENT_ROOT}/$1/web/$2 -f'],
        rewrite_rule => ['^/([^/]+)/(.*)       /$1/web/$2        [last]'],
      },
      {
        # Map bare application directory URLs to allow for auto loading of index files.
        #
        # URLs of the form /app or /app/ are mapped to /app/web/ to auto serve /app/web/index.*
        #
        # 2011-11-30 rrotter
        rewrite_cond => ['%{DOCUMENT_ROOT}/$1/web/ -d'],
        rewrite_rule => ['^/([^/]+)/?$ /$1/web/ [last]'],
      },

      {

        # serve ht widgets from /widgets/<widget name>/web/
        #
        # 2012-12-10 skorner
        rewrite_cond => ['%{DOCUMENT_ROOT}/widgets/$1/web/$2 -f'],
        rewrite_rule => ['^/widgets/([^/]+)/(.*)      /widgets/$1/web/$2      [last]'],
      },


      # FROM SSL

      {
        # Map cgi URLs of the traditional /cgi/app form to the cgi directories within
        # each application repository, if the cgi being requested exists.  Also
        # support a second level of cgi for flexibility.  Any path info formatted
        # arguments are carried along in both cases.
        #
        # URLs are of the form /cgi/app and are mapped to /app/cgi/app, and
        # /cgi/app/subdir/foobar to /app/cgi/subdir/foobar.
        #
        # For URLs of the form /cgi/APP/PATHINFO where a FastCGI socket exists for
        # APP and PATHINFO doesn't match any other existing CGI, the FastCGI socket
        # will be used and PATHINFO arguments carried along. If another script exists
        # that matches PATHINFO (e.g. /imgsrv/pdf), that will be used instead of the
        # FastCGI socket.
        #
        # Order is important; the longer pathname is matched first.
        #
        # The passthrough is required to pick up both the access control and cgi
        # DirectoryMatch defined globally.
        #
        # 2011-04-20 aelkiss
        # 2011-12-12 skorner

        # If /htapps/VHOST/APP/cgi/SCRIPT exists, rewrite /cgi/APP/SCRIPT/PATHINFO
        # to /APP/cgi/SCRIPT/PATHINFO and stop
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$2/cgi/$3 -f'],
        rewrite_rule => ['  ^/(shcgi|cgi)/([^/]+)/([^/]+)(.*)$  /$2/cgi/$3$4        [skip]']
      },

      {
        # If the above rule didn't get used see if /htapps/VHOST/APP/cgi/APP exists,
        # and rewrite /cgi/APP/PATHINFO to /APP/cgi/APP/PATHINFO
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$2/cgi/$2 -f'],
        rewrite_rule => ['  ^/(shcgi|cgi)/([^/]+)(.*)$    /$2/cgi/$2$3'],
      },

      {
        # If there is a PSGI "choke" wrapper, invoke that so that the
        # request is considered for throttling
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$1/cgi/$3.choke -f'],
        rewrite_rule => ['  ^/([^/]+)/(shcgi|cgi)/([^/]+)(.*)$  /$1/cgi/$3.choke$4      [last]'],
      },

      {
        rewrite_rule => ["  ^(/$|/index.html$)      https://${servername}/cgi/crms  [redirect=permanent,last]"],
      },


    ],

    directories           => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        location       => $sdrroot,
        allow_override => ['None'],
        require        =>  'all denied'
      },
      {
        provider              => 'location',
        path                  => '/',
        auth_type             => 'shibboleth',
        require               => 'shibboleth',
        shib_request_settings => { 'requireSession' => '0'}
      },
      {
        # Grant access to necessary directories under the document root:
        # ${sdrroot}/*/cgi
        # ${sdrroot}/*/web
        # ${sdrroot}/cache
        #
        # 2010-10-01 skorner
        provider => 'directorymatch',
        path     => "^(${sdrroot}/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/)(.*)",
        require  => $default_access
      },
      {
        # Enable cgi execution under ${sdrroot}/*/cgi.
        #
        # 2010-10-01 skorner
        provider       => 'directorymatch',
        path           => "^${sdrroot}/([^/]+)/cgi",
        allow_override => 'None',
        options        => '+ExecCGI',
        sethandler     => 'cgi-script',
        require        => 'unmanaged'
      },
      {
        # An Apache handler needs to be established for the "handler" location.
        # This applies the handler to any requests for a resource with a ".sso"
        # extension.
        #
        # Note: this makes *.sso files (and therefore shib session initiation)
        # public to any shib idp, but the alternatives (maintaining separate
        # ACLs for *.sso in each vhost, or devising a scheme with environment
        # variables and ugly IP range regexps) seem unacceptably complex
        provider   => 'files',
        path       => '*.sso',
        sethandler => 'shib-handler',
        require    => 'all granted'
      },
      {
        provider => 'locationmatch',
        path     => '^/shibboleth-sp/main.css',
        require  => 'all granted'
      },

    ],

    allow_encoded_slashes => 'on',

  }

}
