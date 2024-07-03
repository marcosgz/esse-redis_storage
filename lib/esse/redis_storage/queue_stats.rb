# frozen_string_literal: true

module Esse
  module RedisStorage
    module QueueStats
      KEY = "#{Esse::RedisStorage::NAMESPACE}:queues"

      class << self
        extend Forwardable
        def_delegator :redis_connection, :with

        def all
          with { |conn| conn.smembers(KEY) }
        end

        def push(value)
          with { |conn| conn.sadd(KEY, value) }
        end

        def delete(value)
          with { |conn| conn.srem(KEY, value) }
        end

        def clear
          with { |conn| conn.del(KEY) }
        end

        private

        def redis_connection
          Esse.config.redis
        end
      end
    end
  end
end
