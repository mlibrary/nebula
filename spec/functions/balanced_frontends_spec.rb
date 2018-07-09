# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'balanced_frontends' do
  def wrap_with_key(key, array)
    array.map { |val| { key => val } }
  end

  let(:frontends) { %w[service1 service2 service3] * 3 }

  let(:servers) do
    {
      'service1' => %w[svc1_sv1_dc1 svc1_sv2_dc1 svc1_sv1_dc2 svc1_sv2_dc2],
      'service2' => %w[svc2_sv1_dc1 svc2_sv2_dc1 svc2_sv1_dc2 svc2_sv2_dc2],
      'service3' => %w[svc3_sv1_dc2 svc3_sv1_dc3],
    }
  end

  let!(:puppetdb_query) do
    MockFunction.new('puppetdb_query') do |f|
      f.stubbed
       .with(['from', 'resources',
              ['extract', ['title'],
               ['=', 'type', 'Nebula::Balanced_frontend']]])
       .returns(wrap_with_key('title', frontends))
      frontends.each do |frontend|
        f.stubbed
         .with(['from', 'resources',
                ['extract', ['certname'],
                 ['and', ['=', 'type', 'Nebula::Balanced_frontend'],
                  ['=', 'title', frontend]]]])
         .returns(wrap_with_key('certname', servers[frontend]))
      end
    end
  end

  before(:each) do
    stub_loader!

    stub('fact_for') do |d|
      %w[svc1_sv1_dc1 svc1_sv2_dc1 svc2_sv1_dc1 svc2_sv2_dc1].each do |node|
        allow_call(d).with(node, 'datacenter').and_return('dc1')
      end
      %w[svc1_sv1_dc2 svc1_sv2_dc2 svc2_sv1_dc2 svc2_sv2_dc2 svc3_sv1_dc2].each do |node|
        allow_call(d).with(node, 'datacenter').and_return('dc2')
      end
      %w[svc3_sv1_dc3].each do |node|
        allow_call(d).with(node, 'datacenter').and_return('dc3')
      end
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'at datacenter dc1' do
        let(:facts) { os_facts.merge(datacenter: 'dc1') }

        it do
          is_expected.to run.and_return('service1' => %w[svc1_sv1_dc1 svc1_sv2_dc1],
                                        'service2' => %w[svc2_sv1_dc1 svc2_sv2_dc1])
        end
      end

      context 'at datacenter dc2' do
        let(:facts) { os_facts.merge(datacenter: 'dc2') }

        it do
          is_expected.to run.and_return('service1' => %w[svc1_sv1_dc2 svc1_sv2_dc2],
                                        'service2' => %w[svc2_sv1_dc2 svc2_sv2_dc2],
                                        'service3' => %w[svc3_sv1_dc2])
        end
      end

      context 'at datacenter dc3' do
        let(:facts) { os_facts.merge(datacenter: 'dc3') }

        it do
          is_expected.to run.and_return('service3' => %w[svc3_sv1_dc3])
        end
      end
    end
  end
end
