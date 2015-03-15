require 'json'

# Public: HashResult is a clean-formatted
# DTO for the API to return
module Hshtg
  module Models
    class HashtagResult
      # Public: the hashtag string
      attr_accessor :tag

      # Public: the number of times this hashtag appears
      attr_accessor :count

      # Public: Initialize HashtagResult
      #
      # tag - string of text
      # count - integer of times it appears
      #
      # Examples
      #
      #  HashtagResult.new('test', 10)
      def initialize(tag, count)
        @tag   = tag
        @count = count
      end

      def to_json(*a)
        { tag: @tag, count: @count }.to_json(*a)
      end
    end
  end
end
