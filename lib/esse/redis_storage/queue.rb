# frozen_string_literal: true

module Esse
  module RedisStorage
    class Queue
      include Enumerable
      extend Forwardable
      def_delegator :redis_connection, :with

      GROUP = "queue"
      SEPARATOR = ":"

      attr_reader :name

      def self.batch_id
        SecureRandom.uuid
      end

      def self.for(repo:, attribute_name: nil)
        name = [repo.index.index_name, repo.repo_name, attribute_name].compact.join(SEPARATOR)
        new(name: name)
      end

      def initialize(name:)
        @name = [Esse::RedisStorage::NAMESPACE, GROUP, name].compact.join(SEPARATOR)
      end

      # Enqueue a batch of ids to process
      # @param id [String] The batch id
      # @param values [Array<String>] The values of the batch
      def enqueue(id: nil, values: [])
        return if values.nil? || values.empty?

        batch_id = id || self.class.batch_id
        with do |conn|
          conn.hset(name, batch_id, values.join(","))
        end
        batch_id
      end

      # Fetch and remove a batch of ids to process from the queue using batch_id
      # @param batch_id [String] The batch id to fetch
      # @yield [Array<String>] The values of the batch
      def fetch(batch_id)
        with do |conn|
          values = conn.hget(name, batch_id)
          return unless values

          yield values.split(",")
          conn.hdel(name, batch_id)
        end
      end

      def delete(batch_id)
        with do |conn|
          conn.hdel(name, batch_id)
        end
      end

      # Clear the queue
      def clear
        with do |conn|
          conn.del(name)
        end
      end

      # Get the size of the queue
      # @return [Integer] The size of the queue
      def size
        with do |conn|
          conn.hlen(name)
        end
      end

      def each
        with do |conn|
          conn.hscan_each(name, count: 1000) do |batch_id, values|
            yield batch_id, values.split(",")
          end
        end
      end

      private

      def redis_connection
        Esse.config.redis_pool
      end
    end
  end
end
