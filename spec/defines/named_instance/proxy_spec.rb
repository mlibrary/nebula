# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

# TODO: Normalize url_root vs. static_path, which have odd trailing slash handling

describe 'nebula::named_instance::proxy' do
  let(:title)              { 'myapp-mystage' }
  let(:public_hostname)    { 'app.default.invalid' }
  let(:url_root)           { '/' }
  let(:protocol)           { 'http' }
  let(:hostname)           { 'app-host' }
  let(:port)               { 30_000 }
  let(:ssl)                { true }
  let(:ssl_crt)            { 'some.crt' }
  let(:ssl_key)            { 'some.key' }
  let(:path)               { '/nonexistent' }
  let(:static_path)        { '/app' }
  let(:static_directories) { false }
  let(:sendfile_path)      { '/app/storage' }
  let(:public_aliases)     { [] }
  let(:whitelisted_ips)    { [] }

  let(:default_params) do
    {
      public_hostname: public_hostname,
      url_root: url_root,
      protocol: protocol,
      hostname: hostname,
      port: port,
      ssl: ssl,
      ssl_crt: ssl_crt,
      ssl_key: ssl_key,
      path: path,
      static_path: static_path,
      static_directories: static_directories,
      sendfile_path: sendfile_path,
      public_aliases: public_aliases,
      whitelisted_ips: whitelisted_ips,
    }
  end
  let(:params) { default_params }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:proxy_config) { "/sysadmin/archive/app-proxies/#{title}.conf" }
      let(:content)      { catalogue.resource('file', proxy_config).send(:parameters)[:content] }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_file(proxy_config).with(
          require: 'File[/sysadmin/archive/app-proxies]',
        )
      end

      it do
        is_expected.to contain_file('/sysadmin/archive/app-proxies').with(
          ensure: 'directory',
          require: 'File[/sysadmin/archive]',
        )
      end

      it do
        is_expected.to contain_file('/sysadmin/archive').with(
          ensure: 'directory',
          require: 'File[/sysadmin]',
        )
      end

      it do
        is_expected.to contain_file('/sysadmin').with(
          ensure: 'directory',
        )
      end

      describe 'access' do
        context 'with no whitelisted ips' do
          it 'uses default non-robot policy' do
            access = <<~EOT
              \ \ <Location />
                  Order allow,deny
                  Allow from all
                  Deny from env=badrobot
                  Deny from env=loadbalancer
                </Location>
            EOT

            expect(content).to include(access)
          end
        end

        context 'with whitelisted ips' do
          let(:whitelisted_ips) { ['1.2.3.4', '1.2.3.5'] }

          it 'enumerates allowed sources' do
            access = <<~EOT
              \ \ <Location />
                  Order Deny,Allow
                  Deny from all
                  Allow from 1.2.3.4
                  Allow from 1.2.3.5
                </Location>
            EOT

            expect(content).to include(access)
          end
        end
      end

      context 'with public hostname aliases' do
        let(:public_aliases) { ['a.default.invalid', 'b.default.invalid'] }

        it 'includes the first alias' do
          expect(content).to include('ServerAlias a.default.invalid')
        end

        it 'includes the second alias' do
          expect(content).to include('ServerAlias b.default.invalid')
        end
      end

      it 'creates an HTTP vhost with ServerName of public_hostname' do
        vhost = <<~EOT
          <VirtualHost *:80>
            ServerName #{public_hostname}
        EOT

        expect(content).to include(vhost)
      end

      it 'creates an HTTPS vhost with ServerName of public_hostname' do
        vhost = <<~EOT
          <VirtualHost *:443>
            ServerName #{public_hostname}
        EOT

        expect(content).to include(vhost)
      end

      it 'uses a logfile matching the instance title' do
        expect(content).to match(%r{CustomLog\s+"/var/log/apache2/#{title}/access.log"\s+combined})
      end

      context 'when Apache should serve SSL for the client' do
        it 'uses the listed ssl certificate' do
          expect(content).to include("SSLCertificateFile /etc/ssl/certs/#{ssl_crt}")
        end
        it 'uses the listed ssl key' do
          expect(content).to include("SSLCertificateKeyFile /etc/ssl/private/#{ssl_key}")
        end
      end

      it 'sets the DocumentRoot' do
        expect(content).to include("DocumentRoot \"#{static_path}\"")
      end

      it 'enables symlinks and disables htaccess for document root' do
        directory = <<~EOT
          <Directory "#{static_path}">
            Options FollowSymlinks
            AllowOverride None
          </Directory>
        EOT

        expect(content).to include(directory)
      end

      it 'enables mod_rewrite' do
        expect(content).to include('RewriteEngine on')
      end

      describe 'proxy rules' do
        it 'rewrites the app URLs to the app server' do
          rewrite = "RewriteRule ^(#{url_root}.*)$ #{protocol}://#{hostname}:#{port}$1 [P]"
          expect(content).to include(rewrite)
        end

        it 'reverse proxies app requests' do
          proxy = "ProxyPassReverse #{url_root} #{protocol}://#{hostname}:#{port}/"
          expect(content).to include(proxy)
        end
      end

      describe 'static assets' do
        context 'when Apache should serve static directories' do
          let(:static_directories) { true }

          it 'has rewrite conditions for files and directories' do
            conditions = <<~EOT
              RewriteCond #{static_path}/$1 -d [OR]
              RewriteCond #{static_path}/$1 -f
              RewriteRule ^#{url_root}(.*)$ #{static_path}/$1 [L]
            EOT

            expect(content).to include(conditions)
          end
        end

        context 'when Apache should not serve static directories' do
          let(:static_directories) { false }

          it 'has rewrite conditions for files but not directories' do
            files = <<~EOT
              RewriteCond #{static_path}/$1 -f
              RewriteRule ^#{url_root}(.*)$ #{static_path}/$1 [L]
            EOT
            directories = "RewriteCond #{static_path}/$1 -d [OR]"

            expect(content).to include(files)
            expect(content).not_to include(directories)
          end
        end
      end

      context 'with an XSendFile path specified' do
        it 'configures XSendFile' do
          sendfile = <<~EOT
            XSendFile On
            RequestHeader Set X-Sendfile-Type X-Sendfile
            XSendFilePath #{sendfile_path}
          EOT

          expect(content).to include(sendfile)
        end
      end
    end
  end
end
