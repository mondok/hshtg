require 'redis' if Hshtg::Util::Utils.gem_available?('redis')
require 'securerandom'

# Public: Redis store for Hashtag objects.  This is a very basic store
# and makes some basic assumptions.  These
# assumptions include that the Redis instance is local and
# that it is solely dedicated to only this data.
module Hshtg
  module Storage
    class RedisStore
      def initialize
        # this only works with localhost
        # TODO: extend this to be configurable - YAML config?
        @client     = Redis.new
        @evict_time = Util::Configuration.tag_time_to_live_in_seconds
      end

      # Public: All values in Redis.  We're using pipelining here
      # to atomically request the keys.
      #
      # returns array of Hashtag
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
          res << Models::Hashtag.new(t.value)
        end
        res
      end

      # Public: Add tags to collection.
      #
      # *tags - array of Hashtag
      #
      # Examples
      #
      #  add_tags(tag1, tag2)
      #
      # returns nothing
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

      # Public: Evict tags that aren't so fresh, but we
      # don't need to handle it directly because
      # Redis expires the keys for us
      #
      # returns nothing
      def evict_old_tags(*)
      end

      # Public: Just return all tags since they are fresh
      #
      # returns array of Hashtag
      def fresh_tags(*)
        all
      end

      # Public: Clear all tags
      #
      # returns nothing
      def clear
        @client.flushall
      end

      # Public: Number of tags
      #
      # returns integer
      def count
        values.count
      end

      # Public: All available tags
      #
      # returns array of Hashtag
      def all
        values
      end
    end
  end
end
