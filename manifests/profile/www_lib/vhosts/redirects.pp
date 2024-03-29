# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::www_lib::vhosts::redirects(
) {

  nebula::apache::redirect_vhost_http { 'mediaindustriesjournal.org':
    serveraliases => [],
  }

  nebula::apache::redirect_vhost_https { 'michiganelt.org':
    serveraliases => ['www.michiganelt.org'],
    target        => 'https://www.press.umich.edu/elt'
  }

  nebula::apache::redirect_vhost_https { 'lib.umich.edu':
    ssl_cn        => 'www.lib.umich.edu',
    serveraliases => ['lib', 'library.umich.edu', 'www.library.umich.edu'],
  }

  nebula::apache::redirect_vhost_https { 'press.umich.edu':
    ssl_cn        => 'www.press.umich.edu',
    serveraliases => ['press.lib.umich.edu', 'press.nslb.umdl.umich.edu']
  }

  nebula::apache::redirect_vhost_https { 'developingwritersbook.org':
    ssl_cn        => 'developingwritersbook.com',
    serveraliases => [
      'developingwritersbook.com',
      'developingwritersbook.net',
      'www.developingwritersbook.com',
      'www.developingwritersbook.net'
    ],
  }

  # Hosted by github pages. We are just redirecting there.
  nebula::apache::redirect_vhost_https { 'heartofdarknessarchive.org':
    target        => 'https://heartofdarknessarchive.org',
    ssl_cn        => 'heartofdarknessarchive.org',
    serveraliases => [
      'heartofdarknessarchive.com',
      'heartofdarknessarchive.net',
      'www.heartofdarknessarchive.com',
      'www.heartofdarknessarchive.net'
    ],
  }

  nebula::apache::redirect_vhost_https { 'digitalculture.org':
    ssl_cn        => 'digitalculture.org',
    serveraliases => [
      'www.digitalculturebooks.com',
      'digitalculturebooks.com',
      'www.digitalculturebooks.org',
      'digitalculturebooks.org',
    ],
  }

  nebula::apache::redirect_vhost_http { 'lgbtheritage.org':
  }

  nebula::apache::redirect_vhost_https { 'theater-historiography.org':
    ssl_cn        => 'theater-historiography.org',
    serveraliases => [
      'www.theater-historiography.com',
      'theater-historiography.com',
      'www.theatre-historiography.com',
      'theatre-historiography.com',
      'www.theatre-historiography.org',
      'theatre-historiography.org',
    ],
  }

  nebula::apache::redirect_vhost_http { 'mazebooks.org':
    serveraliases => ['www.mazebooks.org'],
  }

  nebula::apache::redirect_vhost_http { 'www.maizebooks.org':
    target => 'http://www.publishing.umich.edu/'
  }

  nebula::apache::redirect_vhost_http { 'datainfolit.org':
    serveraliases => ['www.datainformationliteracy.org', 'datainformationliteracy.org'],
  }

  nebula::apache::redirect_vhost_http { 'pk.lib.umich.edu':
    target => 'http://www.lib.umich.edu/pk/'
  }

  nebula::apache::redirect_vhost_http { 'sfx.lib.umich.edu':
    serveraliases => ['sfx.lib'],
    target        => 'http://mgetit.lib.umich.edu/'
  }

  apache::vhost { 'lgbtheritage.org-redirect-http-all':
    priority   => false,
    port       => '80',
    docroot    => false,
    servername => 'www.lgbtheritage.org',
    rewrites   => [
      {
        rewrite_rule => ['^/.*$ http://www.lib.umich.edu/online-exhibits/exhibits/show/lgbtheritage/ [redirect,noescape]']
      }
    ]
  }

  apache::vhost { 'searchtools.lib.umich.edu-redirect-http':
    priority      => false,
    port          => '80',
    docroot       => false,
    servername    => 'searchtools.lib.umich.edu',
    serveraliases => ['searchtools.lib'],
    rewrites      => [
      {
        rewrite_cond => ['%{QUERY_STRING} func=native-link'],
        rewrite_rule => ['^/(V|V/.*)$ http://www.lib.umich.edu/V [redirect=permanent,last,noescape]'],
      },
      {
        rewrite_cond => ['%{QUERY_STRING} func=find-db-1(.*)mode=category'],
        rewrite_rule => ['^/(V|V/.*)$ http://www.lib.umich.edu/searchtools#databases/search?  [redirect=permanent,last,noescape]'],
      },
      {
        rewrite_cond => ['%{QUERY_STRING} func=find-db-1'],
        rewrite_rule => ['^/(V|V/.*)$ http://www.lib.umich.edu/searchtools#databases? [redirect=permanent,last,noescape]'],
      },
      {
        rewrite_rule => ['^/.*$ http://www.lib.umich.edu/searchtools? [redirect=permanent,last,noescape]']
      }
    ]

  }

}
