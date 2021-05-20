# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::apache::authz_umichlib' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to compile }

      context '???' do
        let(:params) do
          {
            dbd_params: 'user=somebody,pass=whatever,server=whatever',
            oracle_home: '/oracle/home',
            oracle_servers: {
              'myserver1' => %w[ORCL.MYSERVER1_ALIAS1 ORCL.MYSERVER1_ALIAS2],
              'myserver2' => %w[ORCL.MYSERVER2_ALIAS1 ORCL.MYSERVER2_ALIAS2],
            },
            oracle_sid: 'abcd',
            oracle_port: 1234,
          }
        end

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
      end

      context 'with two servers with two aliases each' do
        let(:params) do
          {
            dbd_params: 'invalid_default_dbd_params',
            oracle_servers: {
              'myserver1' => %w[ORCL.MYSERVER1_ALIAS1 ORCL.MYSERVER1_ALIAS2],
              'myserver2' => %w[ORCL.MYSERVER2_ALIAS1 ORCL.MYSERVER2_ALIAS2],
            },
          }
        end

        it { is_expected.to contain_package('libdbd-oracle-perl') }
        it { is_expected.to contain_package('libaprutil1-dbd-oracle') }

        describe 'installs and configures the oracle client' do
          it { is_expected.to contain_package('oracle-instantclient12.1-basic') }
          it { is_expected.to contain_package('oracle-instantclient12.1-devel') }

          it do
            is_expected.to contain_file('/etc/ld.so.conf.d/oracle-instantclient.conf')
              .with_content("/usr/lib/oracle/12.1/client64/lib\n")
              .that_notifies('Exec[oracle driver ldconfig]')
          end

          it do
            is_expected.to contain_exec('oracle driver ldconfig')
              .with_command('/sbin/ldconfig')
              .with_refreshonly(true)
          end
        end

        describe 'loads mod_authz_umichlib' do
          it do
            is_expected.to contain_apache__mod('authz_umichlib')
              .with_package('libapache2-mod-authz-umichlib')
              .with_loadfile_name('zz_authz_umichlib.load')
          end

          it do
            is_expected.to contain_file('authz_umichlib.conf')
              .with_path('/etc/apache2/mods-available/authz_umichlib.conf')
              .with_content(%r{^DBDParams invalid_default_dbd_params$})
              .that_notifies('Class[apache::service]')
          end

          it do
            is_expected.to contain_file_line('/etc/apache2/envvars ORACLE_HOME')
              .with_line('export ORACLE_HOME=/etc/oracle')
              .with_match('/^export ORACLE_HOME=/')
              .with_path('/etc/apache2/envvars')
          end
        end

        describe 'creates the default instant client directory for oracle' do
          it do
            is_expected.to contain_file('/etc/oracle')
              .with_ensure('directory')
          end

          it do
            is_expected.to contain_file('/etc/oracle/network')
              .with_ensure('directory')
              .that_requires('File[/etc/oracle]')
          end

          it do
            is_expected.to contain_file('/etc/oracle/network/admin')
              .with_ensure('directory')
              .that_requires('File[/etc/oracle/network]')
          end
        end

        describe 'configures the oracle client' do
          it do
            is_expected.to contain_file('sqlnet.ora')
              .with_path('/etc/oracle/network/admin/sqlnet.ora')
              .that_notifies('Class[apache::service]')
          end

          def oracle_server_alias(server_alias, server_name)
            %r{#{server_alias}\s+=\n
              \s*\(DESCRIPTION\s+=\n
              \s*\(ADDRESS\s+=\n
              \s*\(PROTOCOL\s+=\s+TCP\)\n
              \s*\(HOST\s+=\s+#{server_name}\.umdl\.umich\.edu\)\n
              \s*\(PORT\s+=\s+[0-9]+\)\n
              \s*\)\n
              \s*\(CONNECT_DATA\s+=\n
              \s*\(SERVER\s+=\s+DEDICATED\)\n
              \s*\(SERVICE_NAME\s+=\s+orcl\.#{server_name}\)\n
            }mx
          end

          it do
            is_expected.to contain_file('tnsnames.ora')
              .with_path('/etc/oracle/network/admin/tnsnames.ora')
              .with_content(oracle_server_alias('ORCL.MYSERVER1_ALIAS1', 'myserver1'))
              .with_content(oracle_server_alias('ORCL.MYSERVER1_ALIAS2', 'myserver1'))
              .with_content(oracle_server_alias('ORCL.MYSERVER2_ALIAS1', 'myserver2'))
              .with_content(oracle_server_alias('ORCL.MYSERVER2_ALIAS2', 'myserver2'))
              .that_notifies('Class[apache::service]')
          end
        end
      end
    end
  end
end
