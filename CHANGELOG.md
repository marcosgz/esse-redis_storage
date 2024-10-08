# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.2 - 2024-08-08
* Add `redis_queue_ttl` configuration option to the `Esse::Config` class.

## 0.1.1 - 2024-08-06
* Add TTL to the enqueued items in the queue.
* Included current time in the rand batch id to be more human readable.

## 0.1.0 - 2024-07-31
* Adjusting queue to allow to enqueue complex objects like Ruby hash and also preserve the primitive type.

## 0.0.2 - 2024-07-18
* The `Esse::RedisStorage::Queue.for` method now support both `repo:` and `attribute_name:` options.

## 0.0.1 - 2024-07-03
The first release of the esse-redis_storage plugin
* Add `redis` and `redis_pool` configuration option to the `Esse::Config` class.
* `Esse::RedisStorage::Pool` class to handle the redis connection pool.
