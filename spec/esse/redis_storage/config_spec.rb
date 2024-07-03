# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::RedisStorage::Config do
  let(:redis) { instance_double(Redis) }

  it "can be configured" do
    Esse.config.redis = redis
    expect(Esse.config.redis).to eq(redis)
  end
end
