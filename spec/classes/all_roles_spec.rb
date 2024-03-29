# frozen_string_literal: true

# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../support/contexts/with_mocked_nodes'

def puppet_role_name_from(path)
  path.strip.gsub('/', '::').gsub(%r{^manifests}, 'nebula').gsub(%r{\.pp}, '')
end

module RSpec::Puppet
  module ManifestMatchers
    class CompileAlongWithAllRoles < Compile
      def initialize(hiera_fixture)
        super()
        @hiera_fixture = hiera_fixture
      end

      def description
        "compile using #{@hiera_fixture} hieradata"
      end

      def failure_message
        "You probably need to add a hiera_config to spec/classes/all_roles_spec.rb:\n #{super()}"
      end

      def failure_message_when_negated
        "You probably need to add a hiera_config to spec/classes/all_roles_spec.rb:\n #{super()}"
      end
    end

    def compile_along_with_all_roles(hiera_fixture)
      RSpec::Puppet::ManifestMatchers::CompileAlongWithAllRoles.new(hiera_fixture)
    end
  end
end

# Tests are run in several roughly equal slices from other *_spec.rb files. This
# results in spec files that each have roughly similar run time, and thus the
# tests run much faster when parallelized.
def test_roles(slice_number = 1, slice_count = 1)
  slice_index = slice_number - 1 # number is 1..n, index is 0..n; using "number" for input to be less confusing
  roles = `find manifests/role -name '*.pp'`.each_line.to_a
  slice = roles.each_slice(roles.size/slice_count + 1).to_a[slice_index]

  slice.each do |file_path|
    role_name = puppet_role_name_from(file_path)
    describe role_name do
      on_supported_os.each do |os, os_facts|
        context "on #{os}" do
          let(:facts) { os_facts }

          let(:hiera_config) { "spec/fixtures/hiera/#{hiera_fixture}_config.yaml" }

          let(:hiera_fixture) do
            [
              # Each item is a pair: [<role prefix or full name>,
              #                       <hiera fixture name>]
              # The first pair that matches will be chosen.
              %w[nebula::role::webhost::htvm hathitrust],
              %w[nebula::role::hathitrust hathitrust],
              %w[nebula::role::chipmunk chipmunk],
              %w[nebula::role::app_host::standalone chipmunk],
              %w[nebula::role::deb_server deb_server],
              %w[nebula::role::kubernetes kubernetes/first_cluster],
              %w[nebula::role::log_host log_host],
              %w[nebula::role::webhost::www_lib_vm www_lib],
              %w[nebula::role::webhost::fulcrum_www_and_app fulcrum],
              %w[nebula::role::fulcrum::standalone fulcrum],
              %w[nebula default],
            ].select { |role_base, _| role_name.start_with? role_base }.first[1]
          end

          let!(:puppetdb_query) do
            MockFunction.new('puppetdb_query') do |f|
              # Everything that runs puppetdb_query should be able to deal
              # with empty results.
              f.stubbed.returns([])
            end
          end

          it { is_expected.to compile_along_with_all_roles(hiera_fixture) }
          it { is_expected.to contain_class('nebula::role::minimum') }
          if role_name.match?(/^nebula::role::hathitrust/)
            it { is_expected.to contain_class('nebula::role::hathitrust') }
          end
        end
      end
    end
  end
end
