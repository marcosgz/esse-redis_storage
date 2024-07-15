# frozen_string_literal: true

module Esse
  module RedisStorage
    class Pool
      extend Forwardable
      def_delegator :@connection, :with

      module ConnectionPoolLike
        def with
          yield self
        end
      end

      def initialize(connection)
        if connection.respond_to?(:with)
          @connection = connection
        else
          @connection = connection ? ::Redis.new(connection) : ::Redis.new
          @connection.extend(ConnectionPoolLike)
        end
      end
    end
  end
end
