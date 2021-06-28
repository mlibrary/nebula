# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::vmhost::host' do
  def contain_vm(name)
    contain_nebula__virtual_machine(name)
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_file('/etc/default/libvirt-guests')
      end

      context 'when given nothing' do
        it { is_expected.not_to contain_vm('vmname') }
      end

      context 'when given a single hostname with an ip' do
        let(:params) do
          {
            vms: {
              'vmname' => {
                'addr' => '1.2.3.4',
              },
            },
          }
        end

        it { is_expected.to contain_vm('vmname').with_build('invalid-default') }
        it { is_expected.to contain_vm('vmname').with_cpus(0) }
        it { is_expected.to contain_vm('vmname').with_disk(0) }
        it { is_expected.to contain_vm('vmname').with_ram(0) }
        it { is_expected.to contain_vm('vmname').with_domain('default.domain.invalid') }
        it { is_expected.to contain_vm('vmname').with_filehost('default.filehost.invalid') }
        it { is_expected.to contain_vm('vmname').with_image_dir('default.image_dir.invalid') }
        it { is_expected.to contain_vm('vmname').with_net_interface('default.iface.invalid') }
        it { is_expected.to contain_vm('vmname').with_netmask('0.0.0.0') }
        it { is_expected.to contain_vm('vmname').with_gateway('10.1.2.3') }
        it { is_expected.to contain_vm('vmname').with_nameservers(['5.5.5.5', '4.4.4.4']) }

        context 'and given a random number of cpus' do
          let(:cpus)   { Faker::Number.between(1, 12).to_i }
          let(:params) { super().merge(cpus: cpus) }

          it { is_expected.to contain_vm('vmname').with_cpus(cpus) }
        end

        context 'and given a random amount of disk space' do
          let(:disk)   { Faker::Number.between(8, 200).to_i }
          let(:params) { super().merge(disk: disk) }

          it { is_expected.to contain_vm('vmname').with_disk(disk) }
        end

        context 'and given a random amount of ram' do
          let(:ram)    { Faker::Number.between(1, 64).to_i }
          let(:params) { super().merge(ram: ram) }

          it { is_expected.to contain_vm('vmname').with_ram(ram) }
        end

        context 'and given a random domain' do
          let(:domain) { Faker::Internet.domain_name }
          let(:params) { super().merge(domain: domain) }

          it { is_expected.to contain_vm('vmname').with_domain(domain) }
        end

        context 'and given a random filehost' do
          let(:domain) { Faker::Internet.domain_name }
          let(:params) { super().merge(filehost: domain) }

          it { is_expected.to contain_vm('vmname').with_filehost(domain) }
        end

        context 'and given a net_interface of eth3' do
          let(:params) { super().merge(net_interface: 'eth3') }

          it { is_expected.to contain_vm('vmname').with_net_interface('eth3') }
        end

        context 'and given a random netmask' do
          let(:ip)     { Faker::Internet.ip_v4_address }
          let(:params) { super().merge(netmask: ip) }

          it { is_expected.to contain_vm('vmname').with_netmask(ip) }
        end

        context 'and given a random gateway' do
          let(:ip)     { Faker::Internet.ip_v4_address }
          let(:params) { super().merge(gateway: ip) }

          it { is_expected.to contain_vm('vmname').with_gateway(ip) }
        end

        context 'and given some random nameservers' do
          let(:nameservers) { Array.new(Faker::Number.between(2, 4)) { Faker::Internet.ip_v4_address } }
          let(:params)      { super().merge(nameservers: nameservers) }

          it { is_expected.to contain_vm('vmname').with_nameservers(nameservers) }
        end

        context 'and given an image_dir of /virt_imgs' do
          let(:params) { super().merge(image_dir: '/virt_imgs') }

          it { is_expected.to contain_vm('vmname').with_image_dir('/virt_imgs') }

          context 'and given a vm with an image_dir of /special_img' do
            let(:params) do
              super().merge(
                vms: {
                  'normalvm' => {
                    'addr' => '1.2.3.2',
                  },
                  'specialvm' => {
                    'addr'      => '1.2.3.3',
                    'image_dir' => '/special_img',
                  },
                },
              )
            end

            it { is_expected.to contain_vm('normalvm').with_image_dir('/virt_imgs') }
            it { is_expected.to contain_vm('specialvm').with_image_dir('/special_img') }
          end
        end
      end

      context 'when given a different hostname with an ip' do
        let(:params) do
          {
            vms: {
              'secondvm' => {
                'addr' => '1.2.3.5',
              },
            },
          }
        end

        it { is_expected.to contain_vm('secondvm') }
      end

      context 'without local storage' do
        let(:params) do
          {
            vms: {
              'itsavm' => {
                'addr' => '1.2.3.4',
              },
            },
          }
        end

        it { is_expected.not_to contain_mount('') }
        it { is_expected.not_to contain_logical_volume('vmimages') }
        it { is_expected.not_to contain_filesystem('/dev/mapper/internal-vmimages') }
      end

      context 'when given a local storage size' do
        let(:params) do
          {
            vms: {
              'itsavm' => {
                'addr' => '1.2.3.4',
              },
            },
            local_storage_size: '42G',
            local_storage: "/#{Faker::Lorem.word}",
          }
        end

        it { is_expected.to contain_vm('itsavm').that_requires("Mount[#{params[:local_storage]}]") }
        it { is_expected.to contain_file(params[:local_storage]).with_ensure('directory') }
        it { is_expected.to contain_mount(params[:local_storage]) }
        it { is_expected.to contain_logical_volume('vmimages').with_size('42G') }
        it { is_expected.to contain_filesystem('/dev/mapper/internal-vmimages').with_fs_type('ext4') }
      end
    end
  end
end
