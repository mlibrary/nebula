
# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::mounts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(networking: { ip: Faker::Internet.ip_v4_address, interfaces: {} }) }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to contain_package('nfs-common') }
      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,ro') }
      it { is_expected.to contain_concat_fragment('monitor nfs /sdr1').with(tag: 'monitor_config', content: { 'nfs' => ['/sdr1'] }.to_yaml) }

      it { is_expected.to contain_mount('/htapps').that_requires('File[/etc/resolv.conf]') }
      it { is_expected.to contain_mount('/htapps').that_requires('Service[bind9]') }
      it {
        is_expected.to contain_concat_fragment('monitor nfs /htapps')
          .with(tag: 'monitor_config', content: { 'nfs' => ['/htapps'] }.to_yaml)
      }
    end
  end
end
