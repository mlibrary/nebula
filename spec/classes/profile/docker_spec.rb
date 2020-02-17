# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::docker' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_concat_file('cri daemon')
          .with_path('/etc/docker/daemon.json')
          .with_format('json')
          .that_notifies('Exec[docker: systemctl daemon-reload]')
          .that_requires('File[/etc/docker]')
      end

      it { is_expected.to contain_file('/etc/docker').with_ensure('directory') }

      it do
        is_expected.to contain_file('/etc/systemd/system/docker.service.d')
          .with_ensure('directory')
          .that_notifies('Exec[docker: systemctl daemon-reload]')
      end

      it do
        is_expected.to contain_exec('docker: systemctl daemon-reload')
          .with_command('/bin/systemctl daemon-reload')
          .with_refreshonly(true)
          .that_notifies('Service[docker]')
      end

      it { is_expected.to contain_service('docker') }

      [
        ['exec-opts', '["native.cgroupdriver=systemd"]'],
        ['log-driver', '"json-file"'],
        ['log-opts', '{"max-size":"100m"}'],
        ['storage-driver', '"overlay2"'],
      ].each do |key, value|
        it do
          is_expected.to contain_concat_fragment("cri daemon #{key}")
            .with_target('cri daemon')
            .with_content("{\"#{key}\":#{value}}")
        end
      end

      it { is_expected.not_to contain_class('docker::compose') }

      context 'without version set' do
        it { is_expected.to contain_class('docker').without_version }
        it { is_expected.not_to contain_apt__pin('docker-ce') }
      end

      context 'with version set to 5' do
        let(:params) { { version: '5' } }

        it { is_expected.to contain_class('docker').with_version('5') }

        it do
          is_expected.to contain_apt__pin('docker-ce').with(
            packages: %w[docker-ce docker-ce-cli],
            version: '5',
          )
        end
      end

      context 'with docker_compose_version set to 1.7.0' do
        let(:params) { { docker_compose_version: '1.7.0' } }

        it do
          is_expected.to contain_class('docker::compose')
            .with_ensure('present')
            .with_version('1.7.0')
        end
      end
    end
  end
end
