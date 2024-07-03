# frozen_string_literal: true

require "esse"
require "redis"
require "forwardable"

require_relative "redis_storage/version"
require_relative "redis_storage/config"
require_relative "redis_storage/pool"

Esse::Config.__send__ :include, Esse::RedisStorage::Config
