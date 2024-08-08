# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::RedisStorage::Config do
  describe "#redis_pool" do
    it "returns a redis pool" do
      Esse.config.redis = Redis.new
      expect(Esse.config.redis_pool).to be_a(Esse::RedisStorage::Pool)
    end
  end

  describe "#redis" do
    it "returns the given redis connection" do
      redis = Redis.new
      Esse.config.redis = redis
      expect(Esse.config.redis).to eq(redis)
    end
  end

  describe "#redis_queue_ttl" do
    it "returns the given queue_ttl" do
      Esse.config.redis_queue_ttl = 10
      expect(Esse.config.redis_queue_ttl).to eq(10)
    end
  end
end
