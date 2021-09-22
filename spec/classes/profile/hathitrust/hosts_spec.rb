# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::hosts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:my_ip) { Faker::Internet.ip_v4_address }
      let(:mysql_ip) { Faker::Internet.ip_v4_address }
      let(:solr_ips) { Array.new(3) { Faker::Internet.ip_v4_address } }
      let(:hostname) { 'thisnode' }
      let(:fqdn) { "#{hostname}.umdl.umich.edu" }

      let(:params) do
        {
          mysql_sdr: mysql_ip,
          mysql_htdev: '2.2.2.2',
          apps_ht: '3.3.3.3',
          solr_search: solr_ips,
          solr_catalog: '4.4.4.4',
          solr_usfeddocs: '6.6.6.6',
          solr_vufind_primary: '7.7.7.7',
          solr_vufind_failover: '8.8.8.8',
        }
      end

      let(:facts) do
        os_facts.merge(
          ipaddress: my_ip,
          hostname: hostname,
          fqdn: fqdn,
        )
      end

      describe '/etc/hosts' do
        let(:file) { '/etc/hosts' }

        it 'maps the ip, fqdn, and hostname' do
          is_expected.to contain_host(hostname).with_ip(my_ip)
          is_expected.to contain_host(hostname).with_host_aliases([fqdn])
        end

        it 'maps 1:1 aliases' do
          is_expected.to contain_host('mysql-sdr').with_ip(mysql_ip)
        end

        it 'unpacks the many search aliases' do
          is_expected.to contain_host('solr-sdr-search-1').with_ip(solr_ips[0])
          is_expected.to contain_host('solr-sdr-search-2').with_ip(solr_ips[1])
        end
      end
    end
  end
end
