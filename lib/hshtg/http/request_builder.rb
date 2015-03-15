require 'oauth'
require 'net/http'

# Public: Helper class for building signed requests
module Hshtg
  module Http
    class RequestBuilder

      # Public: initializes new RequestBuilder.
      #
      # opts - Options to use for building the request
      #
      # Examples
      #
      #  RequestBuilder.new( sign_request: true,
      #                      consumer_key: '123',
      #                      consumer_secret: '23434',
      #                      access_token: '343434',
      #                      access_token_secret: '99435',
      #                      site_url: 'https://site.com',
      #                      endpoint: '/api.json',
      #                      accept: 'application/json',
      #                      content_type: 'application/json')
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

      # Public: Build a request and http connection.
      #
      # Returns [http, request]
      def build_request
        uri          = @config[:endpoint]
        http         = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.start
        request = build_request_stream(uri)
        return http, request
      end

      private

      # Internal: Creates the request stream and signs it for OAuth.
      #
      # uri - URI used for initializing the HTTP request
      #
      # Returns http request
      def build_request_stream(uri)
        headers                 = {}
        headers['ACCEPT']       = @config[:accept]
        headers['Content-Type'] = @config[:content_type]
        req                     = Net::HTTP::Get.new(uri, headers)
        sign_request(req) if @config[:sign_request]
        req
      end

      # Internal: Sign the request for OAuth authentication.
      #
      # req - HTTP request to sign
      #
      # Returns http request
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
