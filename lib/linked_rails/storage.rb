# frozen_string_literal: true

require 'redis'

module LinkedRails
  class Storage
    REDIS_DB = {
      cache: LinkedRails.cache_redis_database,
      persistent: LinkedRails.persistent_redis_database,
      stream: LinkedRails.stream_redis_database
    }.freeze
    KEYS = {
      manifest: 'cache:Manifest',
      redirect_exact: 'cache:Redirect:Exact',
      redirect_prefix: 'cache:Redirect:Prefix'
    }.freeze

    class << self
      %i[xadd].each do |method|
        define_method(method) do |db, *args|
          Redis.new(db: REDIS_DB.fetch(db)).send(method, *args)
        end
      end

      %i[hset hdel hget].each do |method|
        define_method(method) do |db, key, *args|
          Redis.new(db: REDIS_DB.fetch(db)).send(method, KEYS.fetch(key), *args)
        end
      end
    end
  end
end
