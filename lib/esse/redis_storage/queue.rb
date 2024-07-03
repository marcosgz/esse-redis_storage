# frozen_string_literal: true

module Esse
  module RedisStorage
    class Queue
      include Enumerable

      GROUP = "queue"
      SEPARATOR = ":"

      attr_reader :name

      def self.batch_id
        SecureRandom.uuid
      end

      def self.for(repo:)
        name = [repo.index.index_name, repo.repo_name].compact.join(SEPARATOR)
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

      # Retrieve a batch of ids to process
      # @return [Array<String, Array<String>>] The batch id and the values of the batch
      # def dequeue
      #   with do |conn|
      #     # @TODO REDIS 6.2 implements HRANDFIELD
      #     _cursor, arr = conn.hscan(name, 0, count: 1)
      #     batch_id, values = arr.first
      #     return if batch_id.nil? || values.nil?

      #     conn.hdel(name, batch_id)
      #     [batch_id, values.split(",")]
      #   end
      # end

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

      def with
        Esse.config.redis.with { |conn| yield conn }
      end
    end
  end
end

# ids = (1..1000).to_a
# conn = Redis.new
# result = Benchmark.bm do |x|
#   x.report("string ids") do
#     10000.times do
#       conn.set("foo", ids.join(","))
#       conn.get("foo").split(",")
#       conn.del("foo")
#     end
#   end

#   x.report("set ids") do
#     10000.times do
#       conn.sadd("foo", ids)
#       conn.smembers("foo")
#       conn.del("foo")
#     end
#   end

#   x.report("list ids") do
#     10000.times do
#       conn.rpush("foo", ids)
#       conn.lrange("foo", 0, -1)
#       conn.del("foo")
#     end
#   end
# end

# string ids  1.931814   0.108048   2.039862 (  2.515498)
# set ids  8.701828   0.181777   8.883605 ( 13.685118)
# list ids  8.062618   0.181341   8.243959 ( 11.858064)
