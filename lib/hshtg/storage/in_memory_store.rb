# Public: Generic store for Hashtag objects.
# This is a simple interface that could
# be easily overridden with a distributed store if needed.
module Hshtg
  module Storage
    class InMemoryStore
      def initialize
        @hash_tags = []
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
        @hash_tags.concat(tags.flatten)
      end

      # Public: Evict tags that aren't so fresh
      #
      # age_gt - integer specifying seconds to look back for eviction
      #
      # Examples
      #
      #  store.evict_old_tags(100)
      #
      # returns array of Hashtag
      def evict_old_tags(age_gt = 60)
        fresh_tags(age_gt)
      end

      # Public: Gets fresh tags, evicts stale tags
      #
      # age_gt - integer specifying seconds to look back for eviction
      #
      # Examples
      #
      #  store.fresh_tags(100)
      #
      # returns array of Hashtag
      def fresh_tags(age_gt = 60)
        @hash_tags = @hash_tags.select { |t| t.fresh?(age_gt) }
      end

      # Public: Clear all tags
      #
      # returns nothing
      def clear
        @hash_tags.clear
      end

      # Public: Number of tags
      #
      # returns integer
      def count
        @hash_tags.count
      end

      # Public: All tags currently in memory
      #
      # returns array of Hashtag
      def all
        @hash_tags
      end
    end
  end
end
