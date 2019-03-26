# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::imagemagick' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package('imagemagick') }

      it do
        # I've chosen 1MP as an improvement to 16KP without much
        # thought. I chose not to make it a variable because I don't
        # expect it to ever need to change, and, if it ever does, I
        # don't expect it to need to be different on different machines.
        #
        # Other values were taken from the default jessie config.
        is_expected.to contain_file('/etc/ImageMagick-6/policy.xml').with(
          require: 'Package[imagemagick]',
          content: %r{domain="resource" name="width" value="1MP"},
        )
      end
    end
  end
end
