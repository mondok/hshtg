# Generic store for Hashtag objects.  This is a simple interface that could
# be easily overridden with a distributed store if needed.
module Hshtg
  module Storage
    class InMemoryStore
      def initialize
        @hash_tags = []
      end

      # Add tags to collection
      def add_tags(*tags)
        @hash_tags.concat(tags.flatten)
      end

      # Evict tags that aren't so fresh
      def evict_old_tags(age_gt = 60)
        fresh_tags(age_gt)
      end

      # Get the fresh tags from memory
      def fresh_tags(age_gt = 60)
        @hash_tags = @hash_tags.select { |t| t.fresh?(age_gt) }
        @hash_tags
      end

      # Clear all tags
      def clear
        @hash_tags.clear
      end

      # Tags count
      def count
        @hash_tags.count
      end

      # Tags themselves
      def all
        @hash_tags
      end
    end
  end
end
