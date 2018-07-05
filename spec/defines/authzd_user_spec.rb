# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::authzd_user' do
  let(:title) { Faker::Internet.user_name }
  let(:home) { '/some/where' }
  let(:params) do
    {
      gid: Faker::Internet.user_name,
      home: home,
      key: {
        type: 'ssh-rsa',
        data: 'CCCCCCCCCCCC',
        comment: Faker::Internet.email,
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'users' do
        it { is_expected.to contain_user(title).with(name: title, gid: params[:gid], home: home, managehome: true) }
        it { is_expected.to contain_file("#{home}/.ssh").with(ensure: 'directory', mode: '0700') }

        it 'creates authorized_keys with the given key' do
          is_expected.to contain_file("#{home}/.ssh/authorized_keys")
            .with_content(%r{^#{params[:key][:type]} #{params[:key][:data]} #{params[:key][:comment]}$})
        end
      end
    end
  end
end
