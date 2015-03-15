# Public: Hashtag stores a single tag and
# the time it was created
module Hshtg
  module Models
    class Hashtag
      # Public: the hashtag string
      attr_accessor :tag

      # Public: a downcase version of the hashtag
      attr_accessor :down_tag

      # Public: the time this object was initialized
      attr_accessor :timestamp

      # Public: Initialize Hashtag
      #
      # tag - string of text
      #
      # Examples
      #
      #  Hashtag.new('test')
      def initialize(tag)
        @tag       = tag
        @down_tag  = tag.downcase if tag
        @timestamp = Time.now
      end

      # Public: Determines if this object is 'fresh'.
      #
      # age_gt - Lookback time from the point of object creation
      #
      # Examples
      #
      #  fresh?(10)
      #
      # returns Boolean
      def fresh?(age_gt = 60)
        age_gt ||= 60
        now    = Time.now
        now - age_gt <= @timestamp
      end

      # Public: Gets tag used for group operations.
      #
      # match_case - If true, don't use downcase version
      #
      # Examples
      #
      #  grouping_tag(true)
      #
      # returns String
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
