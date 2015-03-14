# Hashtag stores a single tag and
# the time it was created
module Hshtg
	module Models
		class Hashtag
			attr_accessor :tag
			attr_accessor :down_tag
			attr_accessor :timestamp

			def initialize(tag)
				@tag = tag
				@down_tag = tag.downcase if tag
				@timestamp = Time.now
			end

			# Determine if this tag is stale or not.
			# Our default expiration is 60 seconds.
			def fresh?(expiration = 60)
				expiration ||= 60
				now = Time.now
				now - expiration <= @timestamp
			end

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
