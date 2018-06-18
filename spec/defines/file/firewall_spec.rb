# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::file::firewall' do
  let(:title) { '/etc/firewall.ipv4' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when called /etc/firewall.ipv4' do
        it do
          is_expected.to contain_file(title).with_content(
            %r{\n\n}m,
          )
        end
      end

      context 'when called /opt/firewall.ipv4' do
        let(:title) { '/opt/firewall.ipv4' }

        it { is_expected.to contain_file(title) }
      end

      context 'when called with some rules' do
        let(:params) do
          {
            rules: [
              '-A INPUT -p tcp -m tcp -s 1.1.1.1 -j ACCEPT',
              '-A INPUT -p tcp -m tcp -s 4.4.4.4 -j ACCEPT',
            ],
          }
        end

        [
          %r{^-A INPUT -p tcp -m tcp -s 1\.1\.1\.1 -j ACCEPT$},
          %r{^-A INPUT -p tcp -m tcp -s 4\.4\.4\.4 -j ACCEPT$},
        ].each do |line|
          it { is_expected.to contain_file(title).with_content(line) }
        end
      end
    end
  end
end
