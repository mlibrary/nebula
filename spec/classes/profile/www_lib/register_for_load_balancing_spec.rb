# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
describe 'nebula::profile::www_lib::register_for_load_balancing' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      describe 'exported resources' do
        subject { exported_resources }

        context 'with services set to www-lib' do
          let(:params) { { services: ['www-lib'] } }

          it do
            is_expected.to contain_nebula__haproxy__binding("#{facts[:hostname]} www-lib")
              .with_service('www-lib')
          end

          it { is_expected.not_to contain_nebula__haproxy__binding("#{facts[:hostname]} deepblue") }
        end

        context 'with services set to www-lib and deepblue' do
          let(:params) { { services: %w[www-lib deepblue] } }

          it { is_expected.to contain_nebula__haproxy__binding("#{facts[:hostname]} www-lib") }
          it { is_expected.to contain_nebula__haproxy__binding("#{facts[:hostname]} deepblue") }
        end

        context 'with services set to www-lib-testing' do
          let(:params) { { services: ['www-lib-testing'] } }

          it { is_expected.to contain_nebula__haproxy__binding("#{facts[:hostname]} www-lib-testing") }
          it { is_expected.not_to contain_nebula__haproxy__binding("#{facts[:hostname]} www-lib") }
          it { is_expected.not_to contain_nebula__haproxy__binding("#{facts[:hostname]} deepblue") }
        end
      end
    end
  end
end
