# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::www_lib::vhosts::redirects(
) {

  nebula::apache::redirect_vhost_http { 'mediaindustriesjournal.org':
    serveraliases => [],
  }

  nebula::apache::redirect_vhost_https { 'michiganelt.org':
    serveraliases => []
  }

  nebula::apache::redirect_vhost_http { 'www.michiganelt.org':
    target => 'http://www.press.umich.edu/elt'
  }

  nebula::apache::redirect_vhost_https { 'lib.umich.edu':
    ssl_cn        => 'www.lib.umich.edu',
    serveraliases => ['lib', 'library.umich.edu', 'www.library.umich.edu'],
  }

  nebula::apache::redirect_vhost_https { 'mblem.umich.edu':
    ssl_cn        => 'www.mblem.umich.edu',
    serveraliases => ['mblem.nslb.umdl.umich.edu'],
  }

  nebula::apache::redirect_vhost_https { 'mportfolio.umich.edu':
    ssl_cn        => 'www.mportfolio.umich.edu',
    serveraliases => ['mportfolio.nslb.umdl.umich.edu'],
  }

  nebula::apache::redirect_vhost_https { 'publishing.umich.edu':
    ssl_cn        => 'www.publishing.umich.edu',
    serveraliases => ['publishing'],
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

  nebula::apache::redirect_vhost_https { 'fulcrum.publishing.umich.edu':
    ssl_cn   => 'www.publishing.umich.edu',
    priority => '07',
    target   => 'https://tools.lib.umich.edu/confluence/display/FPS'
  }

  nebula::apache::redirect_vhost_https { 'support.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://tools.lib.umich.edu/confluence/display/FPS',
    serveraliases => ['support.fulcrum.org', 'support.fulcrumservices.org'],
  }

  nebula::apache::redirect_vhost_https { 'northwestern.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/northwestern',
    serveraliases => ['northwestern.fulcrum.org', 'northwestern.fulcrumservices.org'],
  }

  nebula::apache::redirect_vhost_https { 'minnesota.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/minnesota',
    serveraliases => [ 'minnesota.fulcrum.org', 'minnesota.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'michigan.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/michigan',
    serveraliases => [ 'michigan.fulcrum.org', 'michigan.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'indiana.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/indiana',
    serveraliases => [ 'indiana.fulcrum.org', 'indiana.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'pennstate.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/pennstate',
    serveraliases => [ 'pennstate.fulcrum.org', 'pennstate.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'nyupress.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/nyupress',
    serveraliases => [ 'nyupress.fulcrum.org', 'nyupress.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'dialogue.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/dialogue',
    serveraliases => [ 'dialogue.fulcrum.org', 'dialogue.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'fulcrum.org':
    priority      => '14',
    serveraliases => [
      'fulcrum.pub',
      'fulcrumscholar.org',
      'fulcrumscholar.com',
      'fulcrumscholar.net',
      'fulcrumservices.org',
      'fulcrumservices.net',
      '*.fulcrum.org',
      '*.fulcrum.pub',
      '*.fulcrumscholar.org',
      '*.fulcrumscholar.com',
      '*.fulcrumscholar.net',
      '*.fulcrumservices.org',
      '*.fulcrumservices.net',
      '*.heartofdarknessarchive.com',
      'heartofdarknessarchive.com',
      '*.heartofdarknessarchive.org',
      'heartofdarknessarchive.org',
      '*.heartofdarknessarchive.net',
      'heartofdarknessarchive.net',
    ],
  }

  nebula::apache::redirect_vhost_https { 'digitalculture.org':
    ssl_cn        => 'www.digitalculture.org',
    serveraliases => [
      'www.digitalculturebooks.com',
      'digitalculturebooks.com',
      'www.digitalculturebooks.org',
      'digitalculturebooks.org',
    ],
  }

  nebula::apache::redirect_vhost_http { 'lgbtheritage.org':
  }

  nebula::apache::redirect_vhost_https { 'textcreationpartnership.org':
    ssl_cn        => 'www.textcreationpartnership.org',
    serveraliases => ['www.textcreationpartnership.com', 'textcreationpartnership.com'],
  }

  nebula::apache::redirect_vhost_https { 'theater-historiography.org':
    ssl_cn        => 'www.theater-historiography.org',
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

  nebula::apache::redirect_vhost_http { 'beta.lib.umich.edu':
    target => 'http://www.lib.umich.edu/'
  }

  nebula::apache::redirect_vhost_http { 'medsearch.lib.umich.edu':
    serveraliases => ['medsearch', 'medsearch.lib'],
    target        => 'http://www.lib.umich.edu/health-sciences-libraries/medsearch/'
  }

  nebula::apache::redirect_vhost_http { 'm-update.lib.umich.edu':
    serveraliases => ['m-update.lib'],
    target        => 'http://m.lib.umich.edu/'
  }

  nebula::apache::redirect_vhost_http { 'www-update.lib.umich.edu':
    serveraliases => ['www-update.lib'],
    target        => 'http://www.lib.umich.edu/'
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

  nebula::apache::redirect_vhost_http { 'copyright.umich.edu':
    serveraliases => ['www.copyright.umich.edu'],
    target        => 'https://copyright.umich.edu/'
  }

  nebula::apache::www_lib_vhost { 'copyright.umich.edu-redirect-https-all':
    priority      => false,
    ssl           => true,
    ssl_cn        => 'copyright.umich.edu',
    docroot       => false,
    servername    => 'copyright.umich.edu',
    serveraliases => ['www.copyright.umich.edu'],
    rewrites      => [
      {
        rewrite_rule => ['^/.*$ https://www.lib.umich.edu/copyright/?utm_source=copyright.umich.edu&utm_medium=redirect [redirect,noescape]']
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
