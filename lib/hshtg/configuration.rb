require 'uri'

# Configuration class holding the Twitter
# keys as well as the endpoint information.
# In order for the server to work, all tokens must be properly set.
# Constants set at the top for readability.
module Hshtg
	class Configuration
		# Constants
		TWITTER_CONSUMER_KEY_NAME = 'TWITTER_CONSUMER_KEY'
		TWITTER_CONSUMER_SECRET_NAME = 'TWITTER_CONSUMER_SECRET'
		TWITTER_ACCESS_TOKEN_KEY_NAME = 'TWITTER_ACCESS_TOKEN'
		TWITTER_ACCESS_TOKEN_SECRET_NAME = 'TWITTER_ACCESS_TOKEN_SECRET'
		TWITTER_STREAM_URL = '/1.1/statuses/sample.json'
		TWITTER_SITE_URL='https://stream.twitter.com'

		class << self
			def case_sensitive_matching
				@case_sensitive_matching ||= false
			end

			def case_sensitive_matching=(value)
				@case_sensitive_matching = value
			end

			def tag_time_to_live_in_seconds
				@tag_time_to_live_in_seconds ||= 60
			end

			def tag_time_to_live_in_seconds=(value)
				@tag_time_to_live_in_seconds = value.to_i
			end

			def hashtag_storage_class
				@hashtag_storage_class ||= Hshtg::Storage::InMemoryStore
			end

			def hashtag_storage_class=(value)
				@hashtag_storage_class = value
			end

			def storage_class
				@hashtag_storage_class ||= Hshtg::Storage::InMemoryStore
			end

			def consumer_key
				ENV[TWITTER_CONSUMER_KEY_NAME]
			end

			def consumer_secret
				ENV[TWITTER_CONSUMER_SECRET_NAME]
			end

			def access_token
				ENV[TWITTER_ACCESS_TOKEN_KEY_NAME]
			end

			def access_token_secret
				ENV[TWITTER_ACCESS_TOKEN_SECRET_NAME]
			end

			# Determine if all the API keys are set.  This could arguably be moved
			# into a more appropriate module.
			def is_valid?
				!(consumer_key.nil? || consumer_secret.nil? || access_token.nil? || access_token_secret.nil?)
			end

			def streaming_endpoint
				encoded_url = URI.encode("#{TWITTER_SITE_URL}#{TWITTER_STREAM_URL}".strip)
				URI.parse(encoded_url)
			end

			def site_url
				TWITTER_SITE_URL
			end

			def to_s
				to_a.join(',')
			end

			def to_a
				[
					"Case Sensitivity: #{case_sensitive_matching}",
					"Hashtag TTL: #{tag_time_to_live_in_seconds}",
					"Storage Type: #{hashtag_storage_class}",
					"Streaming Endpoint: #{streaming_endpoint}",
					"Valid Keys: #{is_valid?}"
				]
			end
		end
	end
end
