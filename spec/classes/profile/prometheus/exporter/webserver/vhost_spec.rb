# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::webserver::vhost' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to compile }

      context "with apache configured for testing" do
        let(:params) { { testing: true } }

        def have_vhost
          contain_apache__vhost("prometheus-webserver-exporter")
        end

        it { is_expected.to compile }
        it { is_expected.to have_vhost.with_port(9180) }
      end
    end
  end
end
