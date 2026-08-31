# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::tesseract" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "installs tesseract-ocr" do
        is_expected.to contain_package("tesseract-ocr")
      end

      it "installs tesseract-ocr-ell" do
        is_expected.to contain_package("tesseract-ocr-ell")
      end
    end
  end
end
