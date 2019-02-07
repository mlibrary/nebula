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

      # Comments after this one are the exact text from Debian's default
      # /etc/logrotate.conf file, which is the same both in jessie and
      # in stretch.

      # # see "man logrotate" for details
      # # rotate log files weekly
      # weekly
      #
      # # keep 4 weeks worth of backlogs
      # rotate 4
      #
      # # create new (empty) log files after rotating old ones
      # create
      #
      # # uncomment this if you want your log files compressed
      # #compress
      #
      # # packages drop log rotation information into this directory
      # include /etc/logrotate.d
      it 'sets debian defaults in /etc/logrotate.conf' do
        is_expected.to contain_logrotate__conf('/etc/logrotate.conf').with(
          create: true,
          rotate_every: 'weekly',
          rotate: 4,
        )
      end

      # # no packages own wtmp, or btmp -- we'll rotate them here
      # /var/log/wtmp {
      #     missingok
      #     monthly
      #     create 0664 root utmp
      #     rotate 1
      # }
      it "contains debian's wtmp logrotate config" do
        is_expected.to contain_logrotate__rule('debian_wtmp').with(
          path: '/var/log/wtmp',
          missingok: true,
          rotate_every: 'month',
          create_mode: '0664',
          create_owner: 'root',
          create_group: 'utmp',
          rotate: 1,
        )
      end

      # /var/log/btmp {
      #     missingok
      #     monthly
      #     create 0660 root utmp
      #     rotate 1
      # }
      it "contains debian's btmp logrotate config" do
        is_expected.to contain_logrotate__rule('debian_btmp').with(
          path: '/var/log/btmp',
          missingok: true,
          rotate_every: 'month',
          create_mode: '0660',
          create_owner: 'root',
          create_group: 'utmp',
          rotate: 1,
        )
      end
    end
  end
end
