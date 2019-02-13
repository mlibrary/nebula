# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tools_lib::jdk' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default attributes' do
        it 'installs from AdoptOpenJDK releases' do
          is_expected.to contain_java__oracle('jdk8')
            .with_url(%r{^https://github.com/AdoptOpenJDK/})
        end
      end

      context 'when requesting Oracle JDK' do
        let(:params) { { oracle: true } }

        # We can't test the calculated URL, just that we are not
        # passing an override value.
        it 'installs from Oracle website' do
          is_expected.to contain_java__oracle('jdk8').with_url(nil)
        end
      end

      describe 'AD root certificate' do
        let(:cert_file) { '/etc/ssl/certs/its-dc02.adsroot.itcs.umich.edu.crt' }

        it { is_expected.to contain_file(cert_file) }

        it do
          is_expected.to contain_java_ks('ITS ActiveDirectory Root certificate')
            .with(certificate: cert_file,
                  target: '/usr/lib/jvm/jdk1.8.0_202/jre/lib/security/cacerts')
        end
      end
    end
  end
end
