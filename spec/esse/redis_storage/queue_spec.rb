# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::RedisStorage::Queue do
  before do
    Esse.config.redis = Redis.new
  end

  describe ".for" do
    before do
      stub_esse_index(:animals) do
        repository(:cat, const: true) {}
        repository(:dog, const: true) {}
      end
    end

    it "returns a queue for the given index" do
      model = described_class.for(repo: AnimalsIndex::Cat)
      expect(model).to be_an_instance_of(described_class)
      expect(model.name).to eq("esse:queue:animals:cat")
    end

    it "accepts an attribute name" do
      model = described_class.for(repo: AnimalsIndex::Cat, attribute_name: "name")
      expect(model.name).to eq("esse:queue:animals:cat:name")
    end
  end

  describe ".batch_id" do
    it "returns a unique batch id" do
      expect(described_class.batch_id).to be_a(String)
      expect(described_class.batch_id).not_to eq(described_class.batch_id)
    end
  end

  describe "#enqueue" do
    let(:queue) { described_class.new(name: "my-queue") }

    it "generates a random id and enqueues the payload" do
      batch_id = queue.enqueue(values: [1, 2])
      expect(batch_id).to be_a(String)
      expect(Esse.config.redis.hget("esse:queue:my-queue", batch_id)).to eq("[1,2]")
    end

    it "enqueues the payload with the given id" do
      batch_id = queue.enqueue(id: "my-id", values: [1, 2])
      expect(batch_id).to eq("my-id")
      expect(Esse.config.redis.hget("esse:queue:my-queue", batch_id)).to eq("[1,2]")
    end

    it "enqueues the payload using array of objects" do
      batch_id = queue.enqueue(values: [{id: 1}, {id: 2}])
      expect(batch_id).to be_a(String)
      expect(Esse.config.redis.hget("esse:queue:my-queue", batch_id)).to eq(%([{"id":1},{"id":2}]))
    end

    it "accepts a ttl" do
      batch_id = queue.enqueue(values: [1, 2], ttl: 10)
      expect(batch_id).to be_a(String)
      expect(Esse.config.redis.ttl("esse:queue:my-queue")).to be_within(1).of(10)
    end

    it "uses the default ttl from config" do
      Esse.config.redis_queue_ttl = 20
      batch_id = queue.enqueue(values: [1, 2])
      expect(batch_id).to be_a(String)
      expect(Esse.config.redis.ttl("esse:queue:my-queue")).to be_within(1).of(20)
      Esse.config.redis_queue_ttl = nil
    end

    it "does not enqueue empty values" do
      batch_id = queue.enqueue(values: [])
      expect(batch_id).to be_nil
    end

    it "does not enqueue nil values" do
      batch_id = queue.enqueue(values: nil)
      expect(batch_id).to be_nil
    end
  end

  describe "#fetch" do
    let(:queue) { described_class.new(name: "my-queue") }

    before do
      queue.clear
    end

    it "fetches a batch" do
      Esse.config.redis.hset("esse:queue:my-queue", "my-id", '["1","2"]')
      queue.fetch("my-id") do |values|
        expect(values).to eq(%w[1 2])
      end
      expect(Esse.config.redis.hget("esse:queue:my-queue", "my-id")).to be_nil
    end

    it "does not fetch a batch if the id does not exist" do
      queue.fetch("my-id") do |values|
        expect(values).to be_nil
      end
    end

    it "does not remove the batch if yield raises an error" do
      Esse.config.redis.hset("esse:queue:my-queue", "my-id", "[1,2]")
      expect do
        queue.fetch("my-id") do |_values|
          raise "error"
        end
      end.to raise_error("error")
      expect(Esse.config.redis.hget("esse:queue:my-queue", "my-id")).to eq("[1,2]")
    end
  end

  describe "#each" do
    let(:queue) { described_class.new(name: "my-queue") }

    before do
      queue.clear
    end

    it "iterates over each batch" do
      Esse.config.redis.hset("esse:queue:my-queue", "my-id-1", "[1,2]")
      Esse.config.redis.hset("esse:queue:my-queue", "my-id-2", "[3,4]")

      expect { |b| queue.each(&b) }.to yield_successive_args(
        ["my-id-1", [1, 2]],
        ["my-id-2", [3, 4]]
      )

      expect(queue.size).to eq(2)
    end
  end

  describe "#delete" do
    let(:queue) { described_class.new(name: "my-queue") }

    before do
      queue.clear
    end

    it "deletes a batch" do
      Esse.config.redis.hset("esse:queue:my-queue", "my-id", "[1,2]")
      queue.delete("my-id")
      expect(Esse.config.redis.hget("esse:queue:my-queue", "my-id")).to be_nil
    end
  end
end
