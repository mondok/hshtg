# Redis store for Hashtag objects.  This is a very basic store
# and makes some basic assumptions.  These
# assumptions include that the Redis instance is local and
# that it is solely dedicated to only this data.
require 'redis' if Hshtg::Utils.gem_available?('redis')
require 'securerandom'

module Hshtg
  module Storage
    class RedisStore
      def initialize
        # this only works with localhost
        # TODO: extend this to be configurable - YAML config?
        @client     = Redis.new
        @evict_time = Hshtg::Configuration.tag_time_to_live_in_seconds
      end

      # All values in Redis.  We're using pipelining here
      # to atomically request the keys.
      def values
        ks          = @client.keys
        res         = []
        temp_values = []
        @client.pipelined do
          ks.each do |k|
            val = @client.get(k)
            temp_values << val
          end
        end

        # let the pipeline finish to get the futures out
        temp_values.each do |t|
          res << Hshtg::Models::Hashtag.new(t.value)
        end
        res
      end

      # Add tags to collection
      def add_tags(*tags)
        # We're just picking a random Guid to use
        # The assumption here is that this Redis instance is
        # solely dedicated to this app.  It would not fly
        # if this Redis instance were shared.

        key = SecureRandom.uuid

        @client.pipelined do
          tags.flatten.each do |ht|
            @client.set(key, ht.tag)
            @client.expire(key, @evict_time)
          end
        end
      end

      # Evict tags that aren't so fresh, but we
      # don't need to handle it directly because
      # Redis expires the keys for us
      def evict_old_tags(*)
      end

      # Just return all tags (See above)
      def fresh_tags(*)
        all
      end

      # Clear all tags
      def clear
        @client.flushall
      end

      # Tags count
      def count
        values.count
      end

      # Tags themselves
      def all
        values
      end
    end
  end
end
