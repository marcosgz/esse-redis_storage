# Esse redis-storage Plugin

<!-- Extends the [esse](https://github.com/marcosgz/esse) search to use [redis-storage](https://github.com/rails/redis-storage) as the default template engine. -->

This gems is a add-on for the [Esse](https://github.com/marcosgz/esse) search library that allows to use [redis-rb](https://github.com/redis/redis-rb) as the default storage engine for operations like async indexing using [esse-faktory](https://github.com/marcosgz/esse-faktory) or [esse-sidekiq](https://github.com/marcosgz/esse-sidekiq).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'esse-redis-storage'
```

And then execute:

```bash
$ bundle install
```

## Configuration

This gem adds the `redis` configuration option to the `Esse::Config` class.

```ruby
Esse.configure do |config|
  config.redis = ConnectionPool.new(size: 10, timeout: 1) do
    Redis.new(url: ENV.fetch('REDIS_URL', 'redis://0.0.0.0:6379'))
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake none` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcosgz/esse-redis-storage.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
