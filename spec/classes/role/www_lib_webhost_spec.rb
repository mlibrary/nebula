# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::webhost::www_lib' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thisnode', datacenter: 'somedc') }

      it { is_expected.to compile }

      it 'exports a haproxy::binding resource for www-lib' do
        expect(exported_resources).to contain_nebula__haproxy__binding('thisnode www-lib')
          .with(service: 'www-lib', datacenter: 'somedc')
      end

      it 'exports a haproxy::binding resource for deepblue' do
        expect(exported_resources).to contain_nebula__haproxy__binding('thisnode deepblue')
          .with(service: 'deepblue', datacenter: 'somedc')
      end
    end
  end
end
