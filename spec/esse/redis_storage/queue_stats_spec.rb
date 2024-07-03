# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::RedisStorage::QueueStats do
  before do
    Esse.config.redis = Redis.new
    described_class.clear
  end

  it "can push and pop" do
    described_class.push("foo")
    described_class.push("bar")
    expect(described_class.all).to match_array(%w[foo bar])
    described_class.delete("foo")
    expect(described_class.all).to match_array(%w[bar])
    described_class.clear
    expect(described_class.all).to be_empty
  end
end
