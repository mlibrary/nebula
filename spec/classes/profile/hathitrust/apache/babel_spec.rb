# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::apache::babel' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }
      let(:pre_condition) { "include apache" }

      let(:base_params) { {
        sdrroot: '',
        sdremail: '',
        default_access: { enforce: 'all', requires: ['all denied'] },
        haproxy_ips: [],
        ssl_params: {},
        prefix: '',
        domain: 'hathitrust.org',
      } }

      let(:params) { base_params }

      describe "CRMS_INSTANCE" do

        it do 
          is_expected.to contain_apache__vhost('babel.hathitrust.org ssl')
          .with_setenvifnocase([
            "Host ^crms-training.babel.hathitrust.org CRMS_INSTANCE=crms-training",
            "Host ^babel.hathitrust.org CRMS_INSTANCE=production",
          ])
        end

        context("with prod_crms_instance set to false") do
          let(:params) { base_params.merge(prod_crms_instance: false) }
          it do 
            is_expected.to contain_apache__vhost('babel.hathitrust.org ssl')
            .with_setenvifnocase([
              "Host ^crms-training.babel.hathitrust.org CRMS_INSTANCE=crms-training",
            ])
          end
        end

      end
    end
  end
end
