require 'oauth'
require 'net/http'

module Hshtg
  module Http
    class RequestBuilder

      # Initializes a new RequestBuilder
      # Options are:
      #   sign_request
      #   consumer_key
      #   consumer_secret
      #   access_token
      #   access_token_secret
      #   site_url
      #   endpoint
      #   accept
      #   content_type
      def initialize(opts = {})
        @config = { consumer_key:        Util::Configuration.consumer_key,
                    consumer_secret:     Util::Configuration.consumer_secret,
                    access_token:        Util::Configuration.access_token,
                    access_token_secret: Util::Configuration.access_token_secret,
                    site_url:            Util::Configuration.site_url,
                    endpoint:            Util::Configuration.streaming_endpoint,
                    sign_request:        true,
                    accept:              'application/json',
                    content_type:        'application/json' }.merge(opts)
      end

      # request object, returns [http, request]
      def build_request
        uri          = @config[:endpoint]
        http         = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.start
        request = build_request_stream(uri)
        return http, request
      end

      private

      # Creates the request stream and signs it for OAuth
      def build_request_stream(uri)
        headers                 = {}
        headers['ACCEPT']       = @config[:accept]
        headers['Content-Type'] = @config[:content_type]
        req                     = Net::HTTP::Get.new(uri, headers)
        sign_request(req) if @config[:sign_request]
        req
      end

      # Sign the request for OAuth authentication.
      def sign_request(req)
        consumer_key        = @config[:consumer_key]
        consumer_secret     = @config[:consumer_secret]
        site_url            = @config[:site_url]
        access_token        = @config[:access_token]
        access_token_secret = @config[:access_token_secret]

        consumer = OAuth::Consumer.new(consumer_key, consumer_secret, { site: site_url, scheme: :header })

        token_hash = { oauth_token:        access_token,
                       oauth_token_secret: access_token_secret }

        access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
        access_token.sign!(req)
        req
      end
    end
  end
end
