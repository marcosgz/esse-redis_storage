# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::RedisStorage::Config do
  let(:default_config) do
    Esse::RedisStorage::Config::InstanceMethods::REDIS_DEFAULTS
  end

  it "has a default redis_options" do
    expect(Esse.config.redis_options).to eq(default_config)
  end

  it "can be configured" do
    Esse.config.redis_options = {"url" => "redis://redis:6379/1"}
    expect(Esse.config.redis_options).to eq(default_config.merge(url: "redis://redis:6379/1"))
  end
end
