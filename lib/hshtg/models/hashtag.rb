# Hashtag stores a single tag and
# the time it was created
module Hshtg
  module Models
    class Hashtag
      attr_accessor :tag
      attr_accessor :down_tag
      attr_accessor :timestamp

      def initialize(tag)
        @tag       = tag
        @down_tag  = tag.downcase if tag
        @timestamp = Time.now
      end

      # Determine if this tag is stale or not.
      # Our default expiration (age_gt) is 60 seconds.
      def fresh?(age_gt = 60)
        age_gt ||= 60
        now    = Time.now
        now - age_gt <= @timestamp
      end

      # Depending on case, this is a
      # helper to return the right tag
      # to group on.
      def grouping_tag(match_case)
        if match_case
          @tag
        else
          @down_tag
        end
      end
    end
  end
end
