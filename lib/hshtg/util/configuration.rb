require 'uri'

# Public: Configuration class holding the Twitter
# keys as well as the endpoint information.
# In order for the server to work, all tokens must be properly set.
module Hshtg
  module Util
    module Configuration
      module_function

      # Public: Name of the consumer key in ENV
      CONSUMER_KEY_NAME        = 'TWITTER_CONSUMER_KEY'

      # Public: Name of the consumer secret in ENV
      CONSUMER_SECRET_NAME     = 'TWITTER_CONSUMER_SECRET'

      # Public: Name of the access token key in ENV
      ACCESS_TOKEN_KEY_NAME    = 'TWITTER_ACCESS_TOKEN'

      # Public: Name of the access token secret in ENV
      ACCESS_TOKEN_SECRET_NAME = 'TWITTER_ACCESS_TOKEN_SECRET'

      # Public: Stream url path to read from
      STREAM_URL               = '/1.1/statuses/sample.json'

      # Public: Root stream url
      SITE_URL                 ='https://stream.twitter.com'

      # Public: Determines whether to group with case sensitivity
      # and initializes to false
      #
      # returns boolean
      def case_sensitive_matching
        @case_sensitive_matching ||= false
      end

      # Public: Set case sensitivity
      def case_sensitive_matching=(value)
        @case_sensitive_matching = value
      end

      # Public: Determines how long a tag lives in storage and
      # initializes to 60 seconds
      #
      # returns integer
      def tag_time_to_live_in_seconds
        @tag_time_to_live_in_seconds ||= 60
      end

      # Public: Sets tag time to live in storage
      def tag_time_to_live_in_seconds=(value)
        @tag_time_to_live_in_seconds = value
      end

      # Public: Determines which storage class to use for storing tags
      # and initializes to InMemoryStore
      #
      # returns storage interface class
      def hashtag_storage_class
        @hashtag_storage_class ||= Hshtg::Storage::InMemoryStore
      end

      # Public: Sets the storage class
      #
      # Examples
      #
      #  Configuration.hashtag_storage_class(Hshtg::Storage::InMemoryStore)
      def hashtag_storage_class=(value)
        @hashtag_storage_class = value
      end

      # Public: Consumer key used for signing that must be set
      # in an environment variable
      #
      # returns string
      def consumer_key
        ENV[CONSUMER_KEY_NAME]
      end

      # Public: Consumer secret used for signing that must be set
      # in an environment variable
      #
      # returns string
      def consumer_secret
        ENV[CONSUMER_SECRET_NAME]
      end

      # Public: Access token used for signing that must be set
      # in an environment variable
      #
      # returns string
      def access_token
        ENV[ACCESS_TOKEN_KEY_NAME]
      end

      # Public: Access token secret used for signing that must be set
      # in an environment variable
      #
      # returns string
      def access_token_secret
        ENV[ACCESS_TOKEN_SECRET_NAME]
      end

      # Public: Determine if all the API keys are set.  This could arguably be moved
      # into a more appropriate module.
      #
      # returns boolean
      def is_valid?
        !(consumer_key.nil? || consumer_secret.nil? || access_token.nil? || access_token_secret.nil?)
      end

      # Public: Full URI of the endpoint to read from
      #
      # return uri
      def streaming_endpoint
        encoded_url = URI.encode("#{SITE_URL}#{STREAM_URL}".strip)
        URI.parse(encoded_url)
      end

      # Public: Site url root
      #
      # returns string
      def site_url
        SITE_URL
      end

      # Public: Returns string of ENV variable key names
      #
      # returns string
      def to_s
        to_a.join(',')
      end

      # Public: Returns array of ENV variable names
      #
      # returns array
      def env_variable_names
        [
            CONSUMER_KEY_NAME,
            CONSUMER_SECRET_NAME,
            ACCESS_TOKEN_KEY_NAME,
            ACCESS_TOKEN_SECRET_NAME
        ]
      end

      # Public: Returns descriptive array of ENV variable names
      #
      # returns array
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
