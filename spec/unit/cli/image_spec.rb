require "fog"
require "cyoi/cli/image"

describe "cyoi" do
  include Cyoi::Cli::Helpers::Settings
  include SettingsHelper
  include StdoutCapture
  include Aruba::Api
  before { @settings_dir = File.expand_path("~/.cyoi_client_lib") }
  before { Fog.mock!; Fog::Mock.reset }

  describe "cyoi image aws" do
    before do
      setting "provider.name", "aws"
      setting "provider.credentials.aws_access_key_id", "aws_access_key_id"
      setting "provider.credentials.aws_secret_access_key", "aws_secret_access_key"
      setting "provider.region", "us-west-2"
    end

    subject { Cyoi::Cli::Image.new([settings_dir]) }

    let(:fog_compute) { subject.key_pair_cli.provider_client.fog_compute }

    it "does nothing if image_id already set" do
      setting "image.image_id", "ami-123456"
      subject.execute!
      reload_settings!
      settings.image.image_id.should == "ami-123456"
    end

    it "auto-selects Ubuntu 13.04 image in region" do
      subject.execute!
      reload_settings!
      settings.image.image_id.should == "ami-bf1d8a8f"
    end
  end

  describe "cyoi image openstack" do
    before do
      setting "provider.name", "openstack"
      setting "provider.credentials.openstack_username", "username"
      setting "provider.credentials.openstack_api_key", "password"
      setting "provider.credentials.openstack_tenant", "tenant"
      setting "provider.credentials.openstack_auth_url", "http://1.2.3.4:5000/v2.0/tokens"
    end

    subject { Cyoi::Cli::Image.new([settings_dir]) }

    let(:fog_compute) { subject.key_pair_cli.provider_client.fog_compute }

    it "does nothing if image_id already set" do
      setting "image.image_id", "b2d1fa83-67aa-4b6d-b171-5ea466d6d8ab"
      # subject.execute!
      settings.image.image_id.should == "b2d1fa83-67aa-4b6d-b171-5ea466d6d8ab"
    end
  end
end