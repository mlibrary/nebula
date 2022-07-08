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
        sdrroot: '/sdrroot',
        sdremail: 'sdremail@default.invalid',
        default_access: { enforce: 'all', requires: ['all denied'] },
        haproxy_ips: [],
        ssl_params: {},
        prefix: '',
        domain: 'hathitrust.org',
      } }

      let(:params) { base_params }

      describe "CRMS_INSTANCE" do

        let(:babel_env) do
          catalogue.resource('apache::vhost','babel.hathitrust.org ssl')["setenv"]
        end

        it "sets crms_instance production" do 
          expect(babel_env).to include("CRMS_INSTANCE production")
        end

        context("with prod_crms_instance set to false") do
          let(:params) { base_params.merge(prod_crms_instance: false) }
          it "does not set CRMS_INSTANCE env var" do 
            expect(babel_env).not_to include(/^CRMS_INSTANCE/)
          end
        end

      end
    end
  end
end
