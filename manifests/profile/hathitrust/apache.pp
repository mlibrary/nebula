# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache
#
# Install apache for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::apache
class nebula::profile::hathitrust::apache (
  String $gwt_code = ''
) {

  # fcgi?

  class { 'apache':
    default_vhost          => false,
    default_ssl_vhost      => false,
    # changed from default 300
    timeout                => 900,
    # changed from default 15 (puppet), 5 (debian)
    keepalive_timeout      => 2,
    log_formats            => {
      combined => '%a %l %u %t "%r" %>s %b "%{Referer}i" "%{User-Agent}i" %v "%{X-HathiTrust-InCopyright}o"'
    },
    docroot                => '/htapps/babel',
    # configured below by explicitly declaring params for apache::mod::prefork
    # class
    mpm_module             => false,
    serveradmin            => 'lit-ae-systems@umich.edu',
    servername             => 'babel.hathitrust.org',
    # default is 'On'
    trace_enable           => 'Off',
    # default is 'false'
    root_directory_secured => true,
    scriptalias            => undef,

    # TODO virtual host defaults.. where to put these?
    #    setenv            => ['SDRROOT /htapps/babel',
    #                               'SDRDATAROOT /sdr1',
    #                               # TODO use a better address
    #                               'ASSERTION_EMAIL dlxs-system@umich.edu'],
    #    setenvif          => ['Remote_Addr "::1" loopback',
    #    'Remote_Addr "127.0.0.1" loopback'],
    #    aliases           => { aliasmatch => '^/favicon.ico$',
    #    path              => '/htapps/babel/common/web/favicon.ico' }
    #    directoryindex    =>  "index.html"
  }

  class { 'apache::mod::prefork':
    # copypasta from debian 8 config
    startservers           => 10,
    minspareservers        => 10,
    maxspareservers        => 15,
    maxrequestworkers      => 256,
    maxconnectionsperchild => 0
  }

  # TODO

  # ADD
  # <Files ~ "~$">
  #   Require all denied
  # </Files>


  # VERIFY (vhost-defaults.conf)
  # <Directory />
  #    AllowOverride None
  #    Order deny,allow
  #    Deny from all
  # </Directory>
  #
  #
  # ADD (vhost-defaults)
  # <Directory "/htapps/babel">
  #     Options None
  #     AllowOverride None
  #     Order deny,allow
  #     Deny from all
  # </Directory>
  #
  # ADD (vhost-defaults)
  # # Grant access to necessary directories under the document root:
  # # /htapps/babel/*/cgi
  # # /htapps/babel/*/web
  # # /htapps/babel/cache
  # #
  # # 2010-10-01 skorner
  # <DirectoryMatch "^(/htapps/babel/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/|/tmp/fastcgi/)(.*)">
  #   Order allow,deny
  #   Allow from all
  #   Deny from env=badrobot
  #   Deny from env=loadbalancer
  # </DirectoryMatch>
  #
  # ADD (vhost-defaults)
  # # Enable cgi execution under /htapps/babel/*/cgi.
  #
  # 2010-10-01 skorner
  # <DirectoryMatch "^/htapps/babel/([^/]+)/cgi">
  #      AllowOverride None
  #      Options +ExecCGI
  #      SetHandler cgi-script
  # </DirectoryMatch>
  #
  # ADD (vhost-defaults)
  # CustomLog "${APACHE_LOG_DIR}/access.log" combined env=!loopback


  # VERIFY no settings for <Directory /usr/share>
  # VERIFY no settings for <Directory /var/www>>


  # Modules enabled
  #
  # access_compat (but maybe we can get rid of this)
  # alias   WITH CONFIG; TODO VERIFY DEFAULT CONFIG (for icons)
  # authn_core
  # authz_core
  # authz_host
  # autoindex TODO VERIFY DEFAULT CONFIG
  # cgi
  # cosign TODO package as a deb
  # dir WITH CONFIG
  # env
  # expires
  # fastcgi (not provided any more) (with config)
  # filter
  # headers
  # include
  # macro NOPE
  # mime  WITH CONFIG; VERIFY DEFAULT CONFIG
  # mime_magic  WITH CONFIG; VERIFY DEFAULT CONFIG
  # mpm_prefork (DONE with config)
  # negotiation WITH CONFIG; VERIFY DEFAULT CONFIG
  # php7.0 WITH CONFIG; TODO migrate/verify config (AddType rather than the default)
  # proxy (default config is empty)
  # proxy_http
  # remoteip WITH CONFIG; TODO collect haproxy nodes
  # reqtimeout WITH CONFIG; VERIFY DEFAULT CONFIG
  # rewrite
  # setenvif WITH CONFIG; VERIFY DEFAULT CONFIG
  # shib2 WITH CONFIG; TODO:
  # ADD
  #  # An Apache handler needs to be established for the "handler" location.
  #  # This applies the handler to any requests for a resource with a ".sso"
  #  # extension.
  #  #
  #  # Note: this makes *.sso files (and therefore shib session initiation)
  #  # public to any shib idp, but the alternatives (maintaining separate
  #  # ACLs for *.sso in each vhost, or devising a scheme with environment
  #  # variables and ugly IP range regexps) seem unacceptably complex
  #  #
  #  # 2011-12-07 csnavely, skorner
  #  <Files *.sso>
  #    SetHandler shib-handler
  #    CosignProtected Off
  #    Order allow,deny
  #    Allow from all
  #  </Files>
  #
  #  #
  #  # Used for example logo and style sheet in error templates.
  #  #
  #  <IfModule alias_module>
  #    Alias /shibboleth-sp/main.css /usr/share/shibboleth/main.css
  #  </IfModule>
  #  <LocationMatch "^/shibboleth-sp/main.css$">
  #      Order allow,deny
  #      Allow from all
  #      CosignProtected Off
  #  </LocationMatch>

  # status WITH CONFIG; TODO get trusted IPs from hiera

  class { 'apache::mod::remoteip':
    header    => 'X-Client-IP',
    proxy_ips => [] # TODO collect from haproxy nodes
  }

  class { 'apache::mod::status':
    requires => [] # TODO lookup from hiera
  }

  apache::vhost { 'babel.hathitrust.org non-ssl':
    servername      => 'babel.hathitrust.org',
    port            => '80',
    docroot         => '/htapps/babel',
    redirect_status => 'permanent',
    redirect_dest   => 'https://babel.hathitrust.org',
  }

  apache::vhost { 'babel.hathitrust.org ssl':
    servername    => 'babel.hathitrust.org',
    serveraliases => [ 'ictc.babel.hathitrust.org',
    'macc.babel.hathitrust.org',
    'crms-training.babel.hathitrust.org' ],
    port          => '443',
    docroot       => '/htapps/babel',
    ssl           => true,
    ssl_cert      => '/etc/ssl/certs/www.hathitrust.org.crt',
    ssl_key       => '/etc/ssl/private/www.hathitrust.org.key',

    # FROM COMMON

    aliases       => [
      {
        aliasmatch => '^/robots.txt$',
        path       => '/htapps/babel/common/web/robots.txt'
      },
      {
        # Support Google Webmaster Tools by making its verification file available at (2015-05-07 rrotter per roger)
        aliasmatch => '^google$gwt_code.html$',
        path       => "/htapps/babel/common/web/google${gwt_code}.html"
      }
    ],

    #
    # TODO
    # <If "%{HTTP_HOST} == 'crms-training.babel.hathitrust.org'">
    #    SetEnv CRMS_INSTANCE crms-training
    # </If>
    # <Else>
    #    SetEnv CRMS_INSTANCE production
    # </Else>

    rewrites      => [
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
        # Fold ptsearch into pageturner. Remove after 12/31/2011
        #
        # 2010-04-26 aelkiss per roger
        rewrite_rule => ['  ^/(shcgi|cgi)/ptsearch      /$1/pt/search        [redirect,noescape,last]'],
      },

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
        # If there is a FastCGI socket named APP, rewrite /APP/cgi/APP/PATHINFO to
        # /tmp/fastcgi/$APP.fcgi/PATHINFO
        # TODO: needs to be updated for mod_proxy (preferably) or mod_fcgid
        rewrite_cond => ['       /tmp/fastcgi/$3.sock -x'],
        rewrite_rule => ['       ^/([^/]+)/(shcgi|cgi)/([^/]+)(.*)$      /tmp/fastcgi/$3.fcgi$4                  [last]'],

      },

      {
        # If there is a PSGI "choke" wrapper, invoke that so that the
        # request is considered for throttling
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$1/cgi/$3.choke -f'],
        rewrite_rule => ['  ^/([^/]+)/(shcgi|cgi)/([^/]+)(.*)$  /$1/cgi/$3.choke$4      [last]'],
      },

      {
        # babel home page of sorts
        #
        # 2008-10-24 csnavely per suzchap
        rewrite_rule => ['  ^(/$|/index.html$)      https://$hostname/cgi/mb  [redirect=permanent,last]'],
      },

      # TODO
      #   <Location "/">
      #     AuthType    shibboleth
      #     ShibRequestSetting  requireSession 0
      #     require    shibboleth
      #   </Location>

      ],

      # TODO
      # other virtual host configs

  }
}
