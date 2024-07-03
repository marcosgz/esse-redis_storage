# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::RedisStorage do
  it "has a version number" do
    expect(Esse::RedisStorage::VERSION).not_to be_nil
  end

  it "has a namespace" do
    expect(Esse::RedisStorage::NAMESPACE).to eq("esse")
  end
end
