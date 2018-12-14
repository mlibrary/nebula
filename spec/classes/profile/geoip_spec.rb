# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::geoip' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          license_key: 'mykey',
          user_id: '12345',
        }
      end

      it { is_expected.to contain_package('geoip-bin') }
      it { is_expected.to contain_package('geoipupdate') }

      it do
        is_expected.to contain_file('/etc/GeoIP.conf').with_content(<<~GEOIP_CONF)
          LicenseKey mykey
          UserId 12345
          ProductIds 106
        GEOIP_CONF
      end
    end
  end
end
