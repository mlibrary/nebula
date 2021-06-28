# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::virtual_machine' do
  let(:title) { 'vmname' }
  let(:params) { {} }

  def contain_install
    contain_exec("nebula::virtual_machine::#{title}::virt-install")
  end

  def contain_autostart
    contain_exec("nebula::virtual_machine::#{title}::autostart")
  end

  def contain_preseed
    contain_file("/tmp/.virtual.#{title}/preseed.cfg")
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with nothing but the title "vmname"' do
        it do
          is_expected.to contain_file('/tmp/.virtual.vmname').with(
            ensure: 'directory',
          )
        end

        it do
          is_expected.to contain_preseed.that_requires(
            'File[/tmp/.virtual.vmname]',
          )
        end

        [
          %r{^d-i netcfg/choose_interface select eth0$},
          %r{^d-i netcfg/get_ipaddress string 127\.0\.0\.1$},
          %r{^d-i netcfg/get_netmask string 255\.255\.255\.0$},
          %r{^d-i netcfg/get_gateway string 192.168.1.1$},
          %r{^d-i netcfg/get_nameservers string 192.168.1.1$},
          %r{^d-i netcfg/get_hostname string vmname\.default\.invalid$},
          %r{^d-i netcfg/get_domain string default\.invalid$},
          %r{^d-i netcfg/hostname string vmname\.default\.invalid$},
          %r{^d-i apt-setup/local0/repository string http://apt\.puppetlabs\.com stretch puppet5$.*^d-i apt-setup/local0/key string http://files\.default\.invalid/puppetlabs-pc1-keyring\.gpg$}m,
          %r{\swget -O /target/etc/puppetlabs/puppet/puppet\.conf\s.*http://files\.default\.invalid/puppet\.conf}m,
        ].each do |line|
          it { is_expected.to contain_preseed.with_content(line) }
        end

        it do
          is_expected.to contain_package('virtinst').with(
            ensure: 'installed',
          )
        end

        it do
          is_expected.to contain_package('libvirt-clients').with(
            ensure: 'installed',
          )
        end

        it do
          is_expected.to contain_install.that_requires(
            ['Package[virtinst]',
             'Package[libvirt-clients]'],
          ).with(
            creates: '/var/lib/libvirt/images/vmname.img',
            timeout: 600,
            path:    [
              '/usr/bin',
              '/usr/sbin',
              '/bin',
              '/sbin',
            ],
          )
        end

        [
          %r{^/usr/bin/virt-install},
          %r{ -n 'vmname'},
          %r{ -r 1024},
          %r{ --vcpus 2},
          %r{ --location http://ftp\.us\.debian\.org/debian/dists/stretch/main/installer-amd64/},
          %r{ --os-type=linux},
          %r{ --disk '/var/lib/libvirt/images/vmname\.img,size=16'},
          %r{ --network bridge=br0,model=virtio .* --network bridge=br1,model=virtio}m,
          %r{ --console pty,target_type=virtio},
          %r{ --virt-type kvm},
          %r{ --graphics vnc},
          %r{ --extra-args 'auto netcfg/disable_dhcp=true'},
          %r{ --initrd-inject '/tmp/\.virtual\.vmname/preseed\.cfg'},
        ].each do |command|
          it { is_expected.to contain_install.with_command(command) }
        end

        it do
          is_expected.to contain_autostart.that_requires(
            'Exec[nebula::virtual_machine::vmname::virt-install]',
          ).with(
            creates: '/etc/libvirt/qemu/autostart/vmname.xml',
            command: '/usr/bin/virsh autostart vmname',
          )
        end
      end

      context 'with nothing but the title "secondvm"' do
        let(:title) { 'secondvm' }

        it do
          is_expected.to contain_file('/tmp/.virtual.secondvm').with(
            ensure: 'directory',
          )
        end

        it do
          is_expected.to contain_preseed.that_requires(
            'File[/tmp/.virtual.secondvm]',
          )
        end

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/get_hostname string secondvm\.default\.invalid$},
          )
        end

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/hostname string secondvm\.default\.invalid$},
          )
        end

        it { is_expected.to contain_package('virtinst') }
        it { is_expected.to contain_package('libvirt-clients') }

        it do
          is_expected.to contain_install.with_creates(
            '/var/lib/libvirt/images/secondvm.img',
          )
        end

        it do
          is_expected.to contain_install.with_command(
            %r{ -n 'secondvm'},
          )
        end

        it do
          is_expected.to contain_install.with_command(
            %r{ --disk '/var/lib/libvirt/images/secondvm\.img,size=[0-9]+'},
          )
        end

        it do
          is_expected.to contain_install.with_command(
            %r{ --initrd-inject '/tmp/\.virtual\.secondvm/preseed\.cfg'},
          )
        end

        it do
          is_expected.to contain_autostart.with_creates(
            '/etc/libvirt/qemu/autostart/secondvm.xml',
          )
        end

        it do
          is_expected.to contain_autostart.with_command(
            '/usr/bin/virsh autostart secondvm',
          )
        end
      end

      context 'with cpus set to 8' do
        let(:params) { { cpus: 8 } }

        it do
          is_expected.to contain_install.with_command(%r{ --vcpus 8})
        end
      end

      context 'with ram set to 4' do
        let(:params) { { ram: 4 } }

        it { is_expected.to contain_install.with_command(%r{ -r 4096}) }
      end

      context 'with image_dir set to /libvirt-images' do
        let(:params) { { image_dir: '/libvirt-images' } }

        it do
          is_expected.to contain_install.with_command(
            %r{ --disk '/libvirt-images/vmname.img,size=[0-9]+'},
          )
        end

        it do
          is_expected.to contain_install.with_creates(
            '/libvirt-images/vmname.img',
          )
        end
      end

      context 'with image_path set to /mnt/custom.img' do
        let(:params) { { image_path: '/mnt/custom.img' } }

        it do
          is_expected.to contain_install.with_command(
            %r{ --disk '/mnt/custom.img,size=[0-9]+'},
          )
        end

        it do
          is_expected.to contain_install.with_creates(
            '/mnt/custom.img',
          )
        end
      end

      context 'with image_path and image_dir both set' do
        let(:params) do
          { image_path: 'image_path',
            image_dir:  'image_dir' }
        end

        it do
          is_expected.to contain_install.with_command(
            %r{ --disk 'image_path,size=[0-9]+'},
          )
        end

        it { is_expected.to contain_install.with_creates('image_path') }
      end

      context 'with disk set to 64' do
        let(:params) { { disk: 64 } }

        it do
          is_expected.to contain_install.with_command(
            %r{ --disk '[^,']+,size=64'},
          )
        end
      end

      context 'with timeout set to 0' do
        let(:params) { { timeout: 0 } }

        it { is_expected.to contain_install.with_timeout(0) }
      end

      context 'with autostart_path set to /etc/autostart' do
        let(:params) { { autostart_path: '/etc/autostart' } }

        it do
          is_expected.to contain_autostart.with_creates(
            '/etc/autostart/vmname.xml',
          )
        end
      end

      context 'with build set to jessie' do
        let(:params) { { build: 'jessie' } }

        it do
          is_expected.to contain_install.with_command(
            %r{ --location http://ftp\.us\.debian\.org/debian/dists/jessie/main/installer-amd64/},
          )
        end

        it { is_expected.not_to contain_preseed }

        it { is_expected.not_to contain_install.with_command(%r{--initrd-inject}) }
      end

      context 'with domain set to awesome.com' do
        let(:params) { { domain: 'awesome.com' } }

        [
          %r{^d-i netcfg/get_hostname string vmname\.awesome\.com$},
          %r{^d-i netcfg/get_domain string awesome\.com$},
          %r{^d-i netcfg/hostname string vmname\.awesome\.com$},
        ].each do |line|
          it { is_expected.to contain_preseed.with_content(line) }
        end
      end

      context 'with filehost set to gr8storage.biz' do
        let(:params) { { filehost: 'gr8storage.biz' } }

        [
          %r{^d-i apt-setup/local0/repository string http://apt\.puppetlabs\.com stretch puppet5$.*^d-i apt-setup/local0/key string http://gr8storage\.biz/puppetlabs-pc1-keyring\.gpg$}m,
          %r{\swget -O /target/etc/puppetlabs/puppet/puppet\.conf\s.*http://gr8storage\.biz/puppet\.conf}m,
        ].each do |line|
          it { is_expected.to contain_preseed.with_content(line) }
        end
      end

      context 'with netmask set to 0.0.0.0' do
        let(:params) { { netmask: '0.0.0.0' } }

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/get_netmask string 0\.0\.0\.0$},
          )
        end
      end

      context 'with gateway set to 10.0.0.1' do
        let(:params) { { gateway: '10.0.0.1' } }

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/get_gateway string 10\.0\.0\.1$},
          )
        end
      end

      context 'with nameservers set to [1.2.3.4, 4.3.2.1]' do
        let(:params) { { nameservers: ['1.2.3.4', '4.3.2.1'] } }

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/get_nameservers string 1\.2\.3\.4 4\.3\.2\.1$},
          )
        end
      end

      context 'with an addr' do
        let(:params) { { addr: '1.2.3.4' } }

        it { is_expected.to compile }
      end

      context 'with an existing vm' do
        let(:title) { 'invalid_existing_guest' }

        it { is_expected.to compile }
        it { is_expected.not_to contain_install }
      end

      context 'with title set to "myhost.mysub"' do
        let(:title) { 'myhost.mysub' }

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/get_hostname string myhost\.mysub$},
          )
        end

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/get_domain string mysub$},
          )
        end

        it do
          is_expected.to contain_preseed.with_content(
            %r{^d-i netcfg/hostname string myhost\.mysub$},
          )
        end
      end
    end
  end
end
