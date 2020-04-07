# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
describe 'nebula::profile::quod::prod::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thisnode', datacenter: 'somedc') }

      it { is_expected.to compile }

      it 'exports a haproxy::binding resource for quod' do
        expect(exported_resources).to contain_nebula__haproxy__binding('thisnode quod')
          .with(service: 'quod', datacenter: 'somedc')
      end
    end
  end
end
