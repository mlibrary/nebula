# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::hathitrust::solr6::catalog" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { "spec/fixtures/hiera/hathitrust_config.yaml" }

      it { is_expected.to compile }
      it { is_expected.to contain_class("nebula::profile::hathitrust::solr6") }
      it { is_expected.to contain_file("/var/lib/solr/solr.in.sh").with_content(%r{SOLR_PORT=9033}) }

      it {
        expect(subject).to contain_file("/usr/local/bin/index-release")
          .with_content(%r{BASE=/htsolr/catalog})
          .with_content(%r|^SNAP=".snapshot/htsolr-catalog_\${TODAY}"$|)
          .with_content(%r{CORES="catalog"})
          .with_content(%r{/flags/STOPCATALOGRELEASE})
          .with_content(%r{/bin/echo "STOPCATALOGRELEASE flag present})
          .with_content(%r|SEGMENTS=`ls \${BASE}/cores/\${s}/\${SNAP}/data/index/|)
          .with_content(%r{if \[ \${SEGMENTS} -eq 0 \];})
          .without_content(%r{if \[ \${SEGMENTS} -lt 1 \] \|\| \[ \${SEGMENTS} -gt 2 \];})
          .with_content(%r|rm -f \${SYMLINKBASE}/\${s} && ln -s \${BASE}/cores/\${s}/\${SNAP} \${SYMLINKBASE}/\${s}$|)
          .with_content(%r{^# run the first query to initialize catalog solr$})
          .without_content(%r{^# run the first query to initialize lss solr$})
      }

      it {
        expect(subject).to contain_cron("catalog solr index release")
          .with(command: "/usr/local/bin/index-release > /tmp/index-release.log 2>&1 || /usr/bin/mail -s 'foo catalog index release problem' anybody@default.invalid < /tmp/index-release.log")
      }

      context "when on primary site" do
        let(:params) do
          {is_primary_site: true}
        end

        xit {
          expect(subject).to contain_file("/usr/local/bin/index-release")
            .with_content(%r|^if ! curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org/flags/web/catalog-release-\${TODAY} --resolve "babel.hathitrust.org:443:6.5.4.3|)
        }

        it {
          expect(subject).to contain_cron("catalog solr index release")
            .with(hour: 6, minute: 0)
        }
      end

      context "when on mirror site" do
        let(:params) do
          {is_primary_site: false}
        end

        it {
          expect(subject).to contain_file("/usr/local/bin/index-release")
            .without_content(%r{^if ! curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org})
        }

        it {
          expect(subject).to contain_cron("catalog solr index release")
            .with(hour: 5, minute: 55)
        }
      end

      it { is_expected.to contain_class("nebula::profile::loki") }
    end
  end
end
