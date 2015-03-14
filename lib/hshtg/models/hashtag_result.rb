require 'json'

# HashResult is a clean-formatted
# DTO for the API to return
module Hshtg
	module Models
		class HashtagResult
      attr_accessor :tag
      attr_accessor :count

      def initialize(tag, count)
        @tag = tag
        @count = count
      end

      def to_json(*a)
        { tag: @tag, count: @count }.to_json(*a)
      end
		end
	end
end
