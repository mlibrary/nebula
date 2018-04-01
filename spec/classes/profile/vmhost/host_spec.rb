# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::vmhost::host' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when given nothing' do
        it { is_expected.to compile }
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

        it { is_expected.to contain_nebula__virtual_machine('vmname') }

        context 'and given an image_dir of /virt_imgs' do
          let(:params) do
            super().merge(
              defaults: {
                'image_dir' => '/virt_imgs',
              },
            )
          end

          it do
            is_expected.to contain_nebula__virtual_machine('vmname').with(
              image_dir: '/virt_imgs',
            )
          end

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

            it do
              is_expected.to contain_nebula__virtual_machine('normalvm').with(
                image_dir: '/virt_imgs',
              )
            end

            it do
              is_expected.to contain_nebula__virtual_machine('specialvm').with(
                image_dir: '/special_img',
              )
            end
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

        it { is_expected.to contain_nebula__virtual_machine('secondvm') }
      end
    end
  end
end
