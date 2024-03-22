# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::webhost::www_lib_vm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thisnode', datacenter: 'somedc') }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }
      let(:hiera_config) { 'spec/fixtures/hiera/www_lib_config.yaml' }

      include_context 'with mocked puppetdb functions', 'somedc', %w[rolenode], 'nebula::profile::haproxy' => %w[]

      it { is_expected.to compile }

      it { is_expected.to contain_class('Nebula::Profile::Www_lib::Register_for_load_balancing') }
      it { is_expected.to contain_class('php') }

      it { is_expected.to contain_mount('/www') }

      it { is_expected.to contain_apache__vhost('000-default').with(port: 80, ssl: false) }

      it { is_expected.to contain_apache__vhost('000-default-ssl').with(ssl: true, ssl_cert: '/etc/ssl/certs/www.lib.umich.edu.crt') }

      it 'configures shibboleth' do
        is_expected.to contain_class('nebula::profile::shibboleth')
          .with(startup_timeout: 900)
          .with(watchdog_minutes: '*/30')
      end

      it do
        is_expected.to contain_file('/etc/apache2/mods-available/shib2.conf')
          .with_content(%r{SetHandler shib-handler})
      end

      it do
        is_expected.to contain_file('/etc/apache2/mods-enabled/shib2.conf')
          .with_ensure('link')
          .with_target('/etc/apache2/mods-available/shib2.conf')
      end

      it do
        is_expected.to contain_apache__vhost('www.lib-ssl')
          .with(servername: 'www.lib.umich.edu',
                port: 443,
                ssl: true,
                ssl_cert: '/etc/ssl/certs/www.lib.umich.edu.crt')
          .with_error_log_file('error.log')
          .with_custom_fragment(%r{CookieName skynet})
      end

      it 'www.lib vhost has clickstream and access log' do
        expect(catalogue.resource('apache::vhost', 'www.lib-ssl')[:access_logs])
          .to contain_exactly(
            { 'file' => 'access.log', 'format' => 'combined' },
            'file' => 'clickstream.log', 'format' => 'usertrack',
          )
      end

      it do
        is_expected.to contain_concat_fragment('www.lib-ssl-ssl')
          .with_content(%r{^\s*SSLCertificateFile\s*"/etc/ssl/certs/www.lib.umich.edu.crt"$})
      end

      it do
        is_expected.to contain_concat_file('/usr/local/lib/cgi-bin/monitor/monitor_config.yaml')
      end

      # from hiera
      it { is_expected.to contain_host('mysql-web').with_ip('10.0.0.123') }

      it do
        is_expected.to contain_apache__vhost('000-default-ssl')
          .with_aliases([{ 'scriptalias' => '/monitor',
                           'path' => '/usr/local/lib/cgi-bin/monitor' }])
      end

      it do
        is_expected.to contain_apache__vhost('datamart-https')
          .with_servername('datamart.lib.umich.edu')
          .with_error_log_file('datamart.lib/error.log')
      end

      it 'datamart vhost has access log datamart.lib/access.log only' do
        expect(catalogue.resource('apache::vhost', 'datamart-https')[:access_logs])
          .to contain_exactly('file' => 'datamart.lib/access.log', 'format' => 'combined')
      end

      it do
        is_expected.to contain_apache__vhost('mediaindustriesjournal.org-redirect-http')
          .with_redirect_dest('http://www.mediaindustriesjournal.org/')
          .with_serveraliases([])
      end

      it do
        is_expected.to contain_apache__vhost('michiganelt.org-redirect-https')
          .with_redirect_dest('https://www.press.umich.edu/elt')
          .with_serveraliases(['www.michiganelt.org'])
      end

      it do
        is_expected.to contain_apache__vhost('lib.umich.edu-redirect-https')
          .with_redirect_dest('https://www.lib.umich.edu/')
          .with_serveraliases(%w[lib
                                 library.umich.edu
                                 www.library.umich.edu])
      end

      it do
        is_expected.to contain_apache__vhost('theater-historiography.org-redirect-https')
          .with_ssl_cert('/etc/ssl/certs/theater-historiography.org.crt')
          .with_redirect_dest('https://www.theater-historiography.org/')
          .with_serveraliases(%w[www.theater-historiography.com
                                 theater-historiography.com
                                 www.theatre-historiography.com
                                 theatre-historiography.com
                                 www.theatre-historiography.org
                                 theatre-historiography.org])
      end

      it do
        is_expected.to contain_apache__vhost('deepblue-https')
          .with_ssl_cert('/etc/ssl/certs/deepblue.lib.umich.edu.crt')
          .with_servername('deepblue.lib.umich.edu')
          .with_ssl_proxyengine(true)
      end

      it do
        is_expected.to contain_apache__vhost('openmich-https')
          .with_ssl_cert('/etc/ssl/certs/open.umich.edu.crt')
          .with_servername('open.umich.edu')
      end

      it do
        is_expected.to contain_apache__vhost('apps.staff.lib http redirect')
          .with_servername('apps.staff.lib.umich.edu')
      end

      it do
        is_expected.to contain_apache__vhost('apps.staff.lib ssl')
          .with_servername('apps.staff.lib.umich.edu')
          .with_ssl_cert('/etc/ssl/certs/apps.staff.lib.umich.edu.crt')
      end

      it do
        is_expected.to contain_apache__vhost('www.publishing-http')
      end

      it do
        # SSL offloading
        is_expected.to contain_apache__vhost('www.publishing-https')
          .with_servername('https://www.publishing.umich.edu')
          .with_ssl(false)
          .with_port(443)
      end

      it do
        # Name-based multi-site Wordpress
        is_expected.to contain_apache__vhost('publishing-partners-http')
          .with_servername('blog.press.umich.edu')
          .with_serveraliases([
                                'www.theater-historiography.org',
                                'www.digitalculture.org',
                                'www.digitalrhetoriccollaborative.org',
                              ])
      end

      it do
        # SSL offloading
        # Name-based multi-site Wordpress
        is_expected.to contain_apache__vhost('publishing-partners-https')
          .with_servername('https://blog.press.umich.edu')
          .with_ssl(false)
          .with_port(443)
          .with_serveraliases([
                                'www.theater-historiography.org',
                                'www.digitalculture.org',
                                'www.digitalrhetoriccollaborative.org',
                              ])
      end

      it do
        is_expected.to contain_apache__vhost('press-http')
          .with_servername('www.press.umich.edu')
      end

      it do
        is_expected.to contain_apache__vhost('press-https')
          .with_servername('www.press.umich.edu')
          .with_ssl_cert('/etc/ssl/certs/www.press.umich.edu.crt')
          .with_setenv(['HTTPS on', 'PERL_USE_UNSAFE_INC 1'])
      end

      it do
        is_expected.to contain_apache__vhost('apps.lib-https')
          .with(servername: 'apps.lib.umich.edu',
                port: 443,
                ssl: true,
                ssl_cert: '/etc/ssl/certs/apps.lib.umich.edu.crt')
          .with_error_log_file('error.log')
          .with_custom_fragment(%r{CookieName skynet})
      end

      # Files
      it { is_expected.to contain_file('sqlnet.ora') }

      it 'adds custom params to file authz_umichlib.conf' do
        is_expected.to contain_file('authz_umichlib.conf')
          .with_content(%r{DBDParams\s*user=somebody})
      end

      it 'adds custom params to file tnsnames.ora' do
        is_expected.to contain_file('tnsnames.ora')
          .with_content(%r{^ORCL.MYSERVER1_ALIAS1\s+=})
          .with_content(%r{^ORCL.MYSERVER1_ALIAS2\s+=})
          .with_content(%r{^ORCL.MYSERVER2_ALIAS1\s+=})
          .with_content(%r{^ORCL.MYSERVER2_ALIAS2\s+=})
          .with_content(%r{HOST\s+=\s+myserver1.umdl.umich.edu})
          .with_content(%r{HOST\s+=\s+myserver2.umdl.umich.edu})
          .with_content(%r{SID\s+=\s+abcd})
          .with_content(%r{PORT\s+=\s+1234})
      end

      it { is_expected.to contain_cron('purge apache access logs 1/2') }
      it { is_expected.to contain_cron('purge apache access logs 2/2') }
      it { is_expected.to contain_cron('reload fcgi for Press site nightly') }
      it { is_expected.to contain_cron('shibd existence check') }
      it { is_expected.to contain_cron('staff.lib parse') }
      it { is_expected.to contain_cron('Proactively scan the log files for suspcious activity') }
    end
  end
end
