# frozen_string_literal: true

require "esse"
require "redis"

require_relative "redis_storage/version"
require_relative "redis_storage/config"

Esse::Config.__send__ :include, Esse::RedisStorage::Config
