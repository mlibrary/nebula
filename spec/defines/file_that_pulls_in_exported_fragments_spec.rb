# frozen_string_literal: true

# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::file_that_pulls_in_exported_fragments" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context "when title is /tmp/xyz and fragment_tag is abc" do
        let(:title) { "/tmp/xyz" }
        let(:params) { { fragment_tag: "abc" } }

        it { is_expected.to contain_concat("/tmp/xyz") }

        context "when notify is set to Service[hello]" do
          let(:params) { { fragment_tag: "abc", notify: "Service[hello]" } }

          it { is_expected.to contain_concat("/tmp/xyz").that_notifies("Service[hello]") }
        end
      end

      context "when title is /etc/xyz and fragment_tag is abc" do
        let(:title) { "/etc/xyz" }
        let(:params) { { fragment_tag: "abc" } }

        it { is_expected.to contain_concat("/etc/xyz") }
      end
    end
  end
end
