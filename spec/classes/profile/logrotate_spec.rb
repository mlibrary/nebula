# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::logrotate' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it 'sets debian defaults in /etc/logrotate.conf' do
        is_expected.to contain_logrotate__conf('/etc/logrotate.conf').with(
          create: true,
          rotate_every: 'weekly',
          rotate: 4,
        )
      end

      # Debian by default rotates logs for wtmp and btmp, and we see no
      # reason to stop doing that, although we switched them from
      # monthly to weekly, as they can get very large otherwise.
      it "contains debian's wtmp logrotate config" do
        is_expected.to contain_logrotate__rule('wtmp').with(
          path: '/var/log/wtmp',
          missingok: true,
          rotate_every: 'week',
          create_mode: '0664',
          create_owner: 'root',
          create_group: 'utmp',
          rotate: 4,
        )
      end

      it "contains debian's btmp logrotate config" do
        is_expected.to contain_logrotate__rule('btmp').with(
          path: '/var/log/btmp',
          missingok: true,
          rotate_every: 'week',
          create_mode: '0660',
          create_owner: 'root',
          create_group: 'utmp',
          rotate: 4,
        )
      end
    end
  end
end
