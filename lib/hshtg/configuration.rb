require 'uri'

# Configuration class holding the Twitter
# keys as well as the endpoint information.
# In order for the server to work, all tokens must be properly set.
# Constants set at the top for readability.
module Hshtg
  module Configuration
    module_function

    # Constants
    CONSUMER_KEY_NAME        = 'TWITTER_CONSUMER_KEY'
    CONSUMER_SECRET_NAME     = 'TWITTER_CONSUMER_SECRET'
    ACCESS_TOKEN_KEY_NAME    = 'TWITTER_ACCESS_TOKEN'
    ACCESS_TOKEN_SECRET_NAME = 'TWITTER_ACCESS_TOKEN_SECRET'
    STREAM_URL               = '/1.1/statuses/sample.json'
    SITE_URL                 ='https://stream.twitter.com'

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
      @tag_time_to_live_in_seconds = value
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
      ENV[CONSUMER_KEY_NAME]
    end

    def consumer_secret
      ENV[CONSUMER_SECRET_NAME]
    end

    def access_token
      ENV[ACCESS_TOKEN_KEY_NAME]
    end

    def access_token_secret
      ENV[ACCESS_TOKEN_SECRET_NAME]
    end

    # Determine if all the API keys are set.  This could arguably be moved
    # into a more appropriate module.
    def is_valid?
      !(consumer_key.nil? || consumer_secret.nil? || access_token.nil? || access_token_secret.nil?)
    end

    def streaming_endpoint
      encoded_url = URI.encode("#{SITE_URL}#{STREAM_URL}".strip)
      URI.parse(encoded_url)
    end

    def site_url
      SITE_URL
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
