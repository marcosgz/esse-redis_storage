# frozen_string_literal: true

module Esse
  module RedisStorage
    module Config
      def self.included(base)
        base.__send__(:include, InstanceMethods)
      end

      module InstanceMethods
        attr_accessor :redis

        def redis_pool
          @redis_pool ||= Esse::RedisStorage::Pool.new(redis)
        end
      end
    end
  end
end
