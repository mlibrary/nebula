# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::haproxy::binding' do
  let(:title) { 'whatever' }
  let(:params) do
    {
      service: 'myservice',
      datacenter: 'dc',
      hostname: 'thishost',
      ipaddress: '10.1.2.123',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      # needs to exist so binding can realize it
      let(:pre_condition) do
        <<~EOT
          @nebula::haproxy::service { "myservice":
           floating_ip => '10.2.3.124'
          }
          Concat_Fragment <| |>
         EOT
      end

      it do
        is_expected.to contain_concat_fragment('myservice-dc-http thishost binding').with(
          target: '/etc/haproxy/services.d/myservice-http.cfg',
          order: '04',
          content: "server thishost 10.1.2.123:80 track myservice-dc-https-back/thishost cookie s123\n",
          tag: 'myservice-dc-http_binding',
        )
      end

      it do
        is_expected.to contain_concat_fragment('myservice-dc-https thishost binding').with(
          target: '/etc/haproxy/services.d/myservice-https.cfg',
          order: '04',
          content: "server thishost 10.1.2.123:443 check cookie s123\n",
          tag: 'myservice-dc-https_binding',
        )
      end

      it do
        is_expected.to contain_concat_fragment('myservice-dc-http thishost exempt binding').with(
          target: '/etc/haproxy/services.d/myservice-http.cfg',
          order: '06',
          content: "server thishost 10.1.2.123:80 track myservice-dc-https-back/thishost cookie s123\n",
          tag: 'myservice-dc-http_exempt_binding',
        )
      end

      it do
        is_expected.to contain_concat_fragment('myservice-dc-https thishost exempt binding').with(
          target: '/etc/haproxy/services.d/myservice-https.cfg',
          order: '06',
          content: "server thishost 10.1.2.123:443 track myservice-dc-https-back/thishost cookie s123\n",
          tag: 'myservice-dc-https_exempt_binding',
        )
      end

      it { is_expected.to contain_nebula__haproxy__service('myservice') }

      context 'no https offload' do
        let(:params) { super().merge(https_offload: false) }

        it do
          is_expected.to contain_concat_fragment('myservice-dc-https thishost binding')
            .with_content("server thishost 10.1.2.123:443 ssl verify required ca-file /etc/ssl/certs/ca-certificates.crt check cookie s123\n")
        end

        it do
          is_expected.to contain_concat_fragment('myservice-dc-https thishost exempt binding')
            .with_content("server thishost 10.1.2.123:443 ssl verify required ca-file /etc/ssl/certs/ca-certificates.crt track myservice-dc-https-back/thishost cookie s123\n")
        end
      end
    end
  end
end
