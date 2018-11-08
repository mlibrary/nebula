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

  class { 'apache':
    default_vhost          => false,
    default_ssl_vhost      => false,
    # changed from default 300 (copypasta)
    timeout                => 900,
    # changed from default 15 (puppet), 5 (debian) (copypasta)
    keepalive_timeout      => 2,
    log_formats            => {
      combined => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %v \"%{X-HathiTrust-InCopyright}o\"'
    },
    # configured below by explicitly declaring params for apache::mod::prefork class
    mpm_module             => false,
    serveradmin            => 'lit-ae-systems@umich.edu',
    servername             => 'babel.hathitrust.org',
    trace_enable           => 'Off',
    root_directory_secured => true,
    scriptalias            => undef,
    docroot                => false,
    default_mods           => false,
  }

  class { 'apache::mod::prefork':
    # changed from default; copypasta from debian 8 config
    startservers           => 10,
    minspareservers        => 10,
    maxspareservers        => 15,
    maxrequestworkers      => 256,
    maxconnectionsperchild => 0
  }

  # VERIFY no settings for <Directory /usr/share>
  # VERIFY no settings for <Directory /var/www>>


  # Modules enabled
  #
  # access_compat (but maybe we can get rid of this)
  # alias   WITH CONFIG; TODO VERIFY DEFAULT CONFIG (for icons)
  class { 'apache::mod::authn_core': }
  # autoindex TODO VERIFY DEFAULT CONFIG
  class { 'apache::mod::autoindex': }
  class { 'apache::mod::cgi': }
  # dir TODO CONFIG
  class { 'apache::mod::dir': }
  class { 'apache::mod::expires': }
  # fastcgi (not provided any more) (with config)
  # TODO not sure if this is needed
  class { 'apache::mod::include': }
  # include
  # macro NOPE
  # mime  WITH CONFIG; VERIFY DEFAULT CONFIG
  # mime_magic  WITH CONFIG; VERIFY DEFAULT CONFIG
  class { 'apache::mod::mime_magic': }
  # negotiation WITH CONFIG; VERIFY DEFAULT CONFIG
  class { 'apache::mod::negotiation': }
  # php7.0 WITH CONFIG; TODO migrate/verify config (AddType rather than the default)
  class { 'apache::mod::php': }
  # reqtimeout WITH CONFIG; VERIFY DEFAULT CONFIG
  class { 'apache::mod::reqtimeout': }
  class { 'apache::mod::shib': }

  # remoteip WITH CONFIG; TODO collect haproxy nodes
  class { 'apache::mod::remoteip':
    header    => 'X-Client-IP',
    proxy_ips => [] # TODO collect from haproxy nodes
  }

  class { 'apache::mod::status':
    requires => [] # TODO lookup from hiera
  }

  apache::vhost { 'default non-ssl':
    # TODO merge with top-level defaults
    # ServerName localhost
    # # Allow access only from localhost and haproxy, and send a redirect for / so monitoring doesn't get a 403.
    # #
    # # 2012-02-02 aelkiss
    # <Directory "/">
    # AllowOverride none
    # Order deny,allow
    # Deny from all
    # Allow from 127.0.0.1
    # # Allow from haproxy
    # </Directory>
    # # Additionally, allow access from grog & the squishees so they can check the index release & cache warming flags
    # #
    # # 2013-09-30 skorner
    # <DirectoryMatch "^(/htapps/babel/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/|/tmp/fastcgi/)(.*)">
    # AllowOverride none
    # Order deny,allow
    # Deny from all
    # Allow from 127.0.0.1
    # # Allow from haproxy
    # # Allow from grog
    # # Allow from squishees
    # </DirectoryMatch>
    # RewriteEngine On
    # RewriteRule ^(/$|/index.html$) https://babel.hathitrust.org/cgi/mb    [redirect=permanent,last]

    servername         => 'localhost',

    directoryindex     => 'index.html',
    directories        => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        location       => '/',
        allow_override => ['None'],
        require        =>  'all denied'
      }
    ],
    manage_docroot     => false,
    docroot            => '/htapps/babel',

    setenvif           => [
      'Remote_Addr "::1" loopback',
      'Remote_Addr "127.0.0.1" loopback'
    ],
    access_log_file    => "\${APACHE_LOG_DIR}/access.log",
    access_log_format  => 'combined',
    access_log_env_var => 'env=!loopback',
  }

  ['babel', 'catalog', 'm', 'www'].each |String $vhost| {
    apache::vhost { "${vhost}.hathitrust.org non-ssl":
      servername        => $vhost,
      docroot           => false,
      port              => '80',
      redirect_source   => '/',
      redirect_status   => 'permanent',
      redirect_dest     => "https://${vhost}.hathitrust.org",
      access_log_file   => "\${APACHE_LOG_DIR}/${vhost}/access.log",
      access_log_format => 'combined',
      error_log_file    => "\${APACHE_LOG_DIR}/${vhost}/error.log"
    }
  }

  apache::vhost { 'm.catalog.hathitrust.org redirection':
    servername      => 'm.catalog.hathitrust.org',
    docroot         => false,
    port            => '80',
    serveraliases   => ['m.catalog'],
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => 'https://m.hathitrust.org',
  }

  apache::vhost { 'hathitrust canonical name redirection':
    servername      => 'hathitrust.org',
    docroot         => false,
    port            => '80',
    serveraliases   => [
      'www.hathitrust.com',
      'hathitrust.com',
      'www.hathitrust.info',
      'hathitrust.info',
      'www.hathitrust.net',
      'hathitrust.net'
    ],
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => 'https://www.hathitrust.org',
  }

  file { "/etc/ssl/certs/www.hathitrust.org.crt":
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Class['Apache::Service'],
    source  => "puppet:///ssl-certs/www.hathitrust.org.crt"
  }

  file { "/etc/ssl/private/www.hathitrust.org.key":
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    notify  => Class['Apache::Service'],
    source  => "puppet:///ssl-certs/www.hathitrust.org.key"
  }

  apache::vhost { 'babel.hathitrust.org ssl':
    servername     => 'babel.hathitrust.org',
    serveraliases  => [ 'crms-training.babel.hathitrust.org' ],
    port           => '443',
    docroot        => '/htapps/babel',
    ssl            => true,
    ssl_cert       => '/etc/ssl/certs/www.hathitrust.org.crt',
    ssl_key        => '/etc/ssl/private/www.hathitrust.org.key',

    # from babel-common

    aliases        => [
      {
        aliasmatch => '^/robots.txt$',
        path       => '/htapps/babel/common/web/robots.txt'
      },
      {
        # Support Google Webmaster Tools by making its verification file
        # available at (2015-05-07 rrotter per roger)
        aliasmatch => '^google$gwt_code.html$',
        path       => "/htapps/babel/common/web/google${gwt_code}.html"
      },
      {
        aliasmatch => '^/favicon.ico$',
        path       => '/htapps/babel/common/web/favicon.ico'
      },
      {
        # Used for example logo and style sheet in error templates.
        alias => '/shibboleth-sp/main.css',
        path  => '/usr/share/shibboleth/main.css'
      }
    ],

    directoryindex =>  'index.html',

    setenv         => [
      'SDRROOT /htapps/babel',
      'SDRDATAROOT /sdr1',
      # TODO use a better address
      'ASSERTION_EMAIL dlxs-system@umich.edu'
    ],

    setenvifnocase => [
      'Host crms-training\.babel\.hathitrust\.org CRMS_INSTANCE=crms-training',
      'Host babel\.hathitrust\.org CRMS_INSTANCE=production'
    ],

    rewrites       => [
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
        # 2018-11 - checked with roger -- retain indefinitely
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

    ],

    directories    => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        location       => '/htapps/babel',
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
        # /htapps/babel/*/cgi
        # /htapps/babel/*/web
        # /htapps/babel/cache
        #
        # 2010-10-01 skorner
        provider => 'directorymatch',
        location => '^(/htapps/babel/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/|/tmp/fastcgi/)(.*)">',
        require  => {
          enforce  => 'all',
          requires => [
            'not env badrobot',
            'not env loadbalancer'
          ]
        }
      },
      {
        # Enable cgi execution under /htapps/babel/*/cgi.
        #
        # 2010-10-01 skorner
        provider       => 'directorymatch',
        location       => '^/htapps/babel/([^/]+)/cgi',
        allow_override => 'None',
        options        => '+ExecCGI',
        sethandler     =>  'cgi-script'
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
      }
    ]

  }

  # TODO:
  # - default virtual host (for monitoring)
  # - catalog virtual host - DONE
  # - m.babel (deprecate?)
  # - mdp.lib (deprecate?)
  # - www
  # - production sites (catalog aliases, m.hathitrust.org redirect) - DONE
  apache::vhost { 'catalog.hathitrust.org ssl':
    servername        => 'catalog.hathitrust.org',
    port              => 443,
    serveraliases     => ['m.hathitrust.org'],
    manage_docroot    => false,
    docroot           => '/htapps/catalog/web',
    error_log_file    => "\${APACHE_LOG_DIR}/catalog/error.log",
    access_log_file   => '\%{APACHE_LOG_DIR}/catalog/access.log',
    access_log_format => 'combined',
    directoryindex    => 'index.html index.htm index.php index.phtml index.shtml',
    ssl               => true,
    ssl_cert          => '/etc/ssl/certs/www.hathitrust.org.crt',
    ssl_key           => '/etc/ssl/private/www.hathitrust.org.key',

    directories       => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        path           => '/htapps/catalog/web',
        options        => ['FollowSymlinks'],
        allow_override => ['all'],
        require        => {
          enforce  => 'all',
          requires => [
            'not env badrobot',
            'not env loadbalancer'
          ]
        }
      },
      {
        provider => 'directory',
        path     =>  '/htapps/babel/common/web',
        require  => {
          enforce  => 'all',
          requires => [
            'not env badrobot',
            'not env loadbalancer'
          ]
        }
      },
    ],

    aliases           => [
      {
        aliasmatch => '^/favicon.ico$',
        path       => '/htapps/babel/common/web/favicon.ico'
      },
      {
        alias => '/common/',
        path  => '/htapps/babel/common/web/'
      }
    ],

    rewrites          => [
      {

        # redirect top-level page to www.hathitrust.org, but not for mobile or orphanworks host names
        #
        # 2010-11-12 csnavely per jjyork
        #
        # adapted to take effect for catalog.hathitrust.org only after consolidating m.hathitrust.org and
        # orphanworks.hathtrust.org into this virtual host
        #
        # 2012-04-17 skorner per dueberb

        rewrite_cond => '%{HTTP_HOST}    ^(catalog|test\.catalog)  [nocase]',
        rewrite_rule => '^(/$|/index.html$)  https://www.hathitrust.org/  [redirect=permanent,last]'

      }
    ]
  }

  apache::vhost { 'www.hathitrust.org ssl':
    servername        => 'www.hathitrust.org',
    port              => '443',
    manage_docroot    => false,
    docroot           => '/htapps/www',
    error_log_file    => "\${APACHE_LOG_DIR}/www/error.log",
    access_log_file   => "\${APACHE_LOG_DIR}/www/access.log",
    access_log_format => 'combined',
    setenv            => ['SDRROOT /htapps/www'],
    directoryindex    => 'index.html index.htm index.php index.phtml index.shtml',
    ssl               => true,
    ssl_cert          => '/etc/ssl/certs/www.hathitrust.org.crt',
    ssl_key           => '/etc/ssl/private/www.hathitrust.org.key',

    directories       => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        path           => '/htapps/www',
        options        => ['IncludesNoExec','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => {
          enforce  => 'all',
          requires => [
            'not env badrobot',
            'not env loadbalancer'
          ]
        }
      },
      {
        provider => 'directory',
        path     =>  '/htapps/babel/common/web',
        require  => {
          enforce  => 'all',
          requires => [
            'not env badrobot',
            'not env loadbalancer'
          ]
        }
      },
    ],

    aliases           => [
      {
        aliasmatch => '^/favicon.ico$',
        path       => '/htapps/babel/common/web/favicon.ico'
      },
      {
        alias => '/common/',
        path  => '/htapps/babel/common/web/'
      }
    ],

    rewrites          => [
      {
        # Serve static assets through apache
        rewrite_cond => '/htapps/apps/usdocs_registry/public/$1 -f',
        rewrite_rule =>  '^/usdocs_registry/(.*)$  /htapps/apps/usdocs_registry/public/$1 [L]',
      }
    ],

    proxy_pass        => [
      {
        path   => '/usdocs_registry',
        url    => 'http://apps-ht:30001/',
        params => { 'retry' => '2' }
      }
    ],

    headers           => 'set "Strict-Transport-Security" "max-age=31536000"',

  }

}
