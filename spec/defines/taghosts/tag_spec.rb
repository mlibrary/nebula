# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::taghosts::tag" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe "with title apache" do
        let(:title) { "apache" }

        it { is_expected.to compile }

        it do
          expect(exported_resources).to contain_concat__fragment("taghosts #{facts[:networking]["fqdn"]} 100 apache")
            .with_tag("taghosts")
            .with_target("/var/lib/ae/active-servers")
            .with_content(" apache")
        end
      end

      describe "with title python" do
        let(:title) { "python" }

        it { is_expected.to compile }
        it { expect(exported_resources).to contain_concat__fragment("taghosts #{facts[:networking]["fqdn"]} 100 python") }

        context "with order set to 500" do
          let(:params) { {order: "500"} }

          it { is_expected.to compile }
          it { expect(exported_resources).to contain_concat__fragment("taghosts #{facts[:networking]["fqdn"]} 500 python") }
        end
      end
    end
  end
end
