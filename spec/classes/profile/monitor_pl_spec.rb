
# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::monitor_pl' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { directory: '/somewhere' } }
      let(:outfile) { '/somewhere/monitor_config.yaml' }

      it { is_expected.to contain_concat(outfile).with_format('yaml') }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat_fragment('monitor nfs mounts')
            .with(target: outfile, content: "---\nnfs: []\n")
        }
        it {
          is_expected.to contain_concat_fragment('monitor solr cores')
            .with(target: outfile, content: "---\nsolr: []\n")
        }
        it {
          is_expected.to contain_concat_fragment('monitor mysql')
            .with(target: outfile, content: "---\nmysql: \n")
        }
        it {
          is_expected.to contain_concat_fragment('monitor shibboleth')
            .with(target: outfile, content: "---\nshibd: false\n")
        }
      end

      context 'with parameter values' do
        let(:params) do
          {
            directory: '/somewhere',
            nfs_mounts: ['/nfs1', '/nfs2'],
            solr_cores: ['http://solr-something:8081/whatever'],
            mysql: { 'host' => 'mysql-whatever', 'user' => 'someuser',
                     'password' => 'something', 'database' => 'mydatabase' },
            shibboleth: true,
          }
        end

        it {
          is_expected.to contain_concat_fragment('monitor nfs mounts')
            .with(target: outfile, content: YAML.dump('nfs' => params[:nfs_mounts]))
        }
        it {
          is_expected.to contain_concat_fragment('monitor solr cores')
            .with(target: outfile, content: YAML.dump('solr' => params[:solr_cores]))
        }
        it {
          is_expected.to contain_concat_fragment('monitor mysql')
            .with(target: outfile, content: YAML.dump('mysql' => params[:mysql]))
        }
        it {
          is_expected.to contain_concat_fragment('monitor shibboleth')
            .with(target: outfile, content: YAML.dump('shibd' => params[:shibboleth]))
        }
      end
    end
  end
end
