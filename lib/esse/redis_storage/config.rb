# frozen_string_literal: true

module Esse
  module RedisStorage
    module Config
      def self.included(base)
        base.__send__(:include, InstanceMethods)
      end

      module InstanceMethods
        REDIS_DEFAULTS = {
          url: "redis://localhost:6379",
          namespace: "esse",
          pool_size: 5,
          pool_timeout: 5
        }

        def redis_options
          @redis_options ||= REDIS_DEFAULTS.dup
        end

        def redis_options=(options)
          raise ArgumentError, "options must be a Hash" unless options.is_a?(Hash)

          @redis_options = REDIS_DEFAULTS.merge(options.transform_keys(&:to_sym))
        end
      end
    end
  end
end
