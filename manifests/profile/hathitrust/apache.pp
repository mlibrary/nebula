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
  String $gwt_code = ""
) {

  # fcgi?

  class { 'apache':
    default_vhost     => false,
    default_ssl_vhost => false,
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
      { aliasmatch => '^/robots.txt$',
        path       => '/htapps/babel/common/web/robots.txt' },
      # Support Google Webmaster Tools by making its verification file available at (2015-05-07 rrotter per roger)
      { aliasmatch => '^google$gwt_code.html$',
        path       => "/htapps/babel/common/web/google${gwt_code}.html" }
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


>>>>>>> Stashed changes
  }
}
