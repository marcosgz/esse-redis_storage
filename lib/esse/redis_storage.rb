# frozen_string_literal: true

require "esse"
require "redis"
require "multi_json"
require "forwardable"
require "securerandom"

module Esse
  module RedisStorage
    NAMESPACE = "esse"
  end
end

require_relative "redis_storage/version"
require_relative "redis_storage/config"
require_relative "redis_storage/pool"
require_relative "redis_storage/queue_stats"
require_relative "redis_storage/queue"

Esse::Config.__send__ :include, Esse::RedisStorage::Config
