# frozen_string_literal: true

require 'redis'

module LinkedRails
  class Storage
    CLIENT = {
      cache: Redis.new(db: LinkedRails.cache_redis_database),
      persistent: Redis.new(db: LinkedRails.persistent_redis_database),
      stream: Redis.new(db: LinkedRails.stream_redis_database)
    }.freeze
    KEYS = {
      manifest: 'cache:Manifest',
      redirect: 'cache:Redirect'
    }.freeze

    class << self
      %i[xadd].each do |method|
        define_method(method) do |db, *args|
          CLIENT.fetch(db).send(method, *args)
        end
      end

      %i[hset hdel hget].each do |method|
        define_method(method) do |db, key, *args|
          CLIENT.fetch(db).send(method, KEYS.fetch(key), *args)
        end
      end
    end
  end
end
