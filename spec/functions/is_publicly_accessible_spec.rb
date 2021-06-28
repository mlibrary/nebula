# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'is_publicly_accessible' do
  let(:facts) { { 'networking' => { 'interfaces' => interfaces } } }
  let(:interfaces) { { 'lo' => { 'ip' => '127.0.0.1' } } }

  context 'with no internet connection' do
    it { is_expected.to run.and_return(false) }
  end

  context 'with the ip address 10.1.2.3' do
    let :interfaces do
      super().merge('eth0' => { 'ip' => '10.1.2.3' })
    end

    it { is_expected.to run.and_return(false) }

    context 'and with a nil ip address' do
      let :interfaces do
        super().merge('hfdlksajh' => { 'ip' => nil })
      end

      it { is_expected.to run.and_return(false) }
    end

    context 'and with the ip address 12.34.56.78' do
      let :interfaces do
        super().merge('eth1' => { 'ip' => '12.34.56.78' })
      end

      it { is_expected.to run.and_return(true) }

      context 'and with a nil ip address' do
        let :interfaces do
          super().merge('hfdlksajh' => { 'ip' => nil })
        end

        it { is_expected.to run.and_return(true) }
      end
    end

    context 'and with the ip address 21.43.65.87' do
      let :interfaces do
        super().merge('eth1' => { 'ip' => '21.43.65.87' })
      end

      it { is_expected.to run.and_return(true) }
    end
  end

  context 'with the ip address 172.20.12.34' do
    let :interfaces do
      super().merge('eth0' => { 'ip' => '172.20.12.34' })
    end

    it { is_expected.to run.and_return(false) }
  end

  context 'with the ip address 192.168.1.123' do
    let :interfaces do
      super().merge('eth0' => { 'ip' => '192.168.1.123' })
    end

    it { is_expected.to run.and_return(false) }
  end

  context 'with no interfaces set' do
    let(:facts) { { 'networking' => {} } }

    it { is_expected.to run.and_return(false) }
  end
end
