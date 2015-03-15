require 'webrick'
require 'json'

# Public: This is the Webrick endpoint for
# serving requests down to the client
module Hshtg
  module Http
    class HttpEndpoint < WEBrick::HTTPServlet::AbstractServlet
      include Util::HshtgLogger

      # Public: WEBrick GET request handler
      #
      # request - the HTTP request
      # response - the HTTP response
      #
      # returns HTTP response
      def do_GET (request, response)
        @request  = request
        @response = response
        logger.info("GET #{@request.path} hit")

        if @request.path.downcase.include?('/top')
          handle_top_request

        elsif @request.path == '/'
          generic_response(code: 200, file: './html/index.html')

        elsif @request.path == '/live'
          generic_response(code: 200, file: './html/live.html')

        elsif @request.path == '/health'
          health_check_request

        else
          generic_response
        end
      end

      # Public: WEBrick HEAD request handler
      #
      # request - the HTTP request
      # response - the HTTP response
      #
      # returns HTTP response
      def do_HEAD (request, response)
        @request  = request
        @response = response

        logger.info("HEAD #{@request.path} hit")
        controller                 = Stream::StreamController.instance
        @response.header['Status'] = controller.nil? ? 'down' : 'up'
      end

      private

      # Internal: Handles a request to the healthcheck HTML page.
      #
      # Returns nothing
      def health_check_request
        controller = Stream::StreamController.instance
        if controller
          config_vals = Util::Configuration.to_a.join("\n")
          body        = "status: up\nstarted_at: #{controller.started_at}\n#{config_vals}"
        else
          body = 'status: down'
        end

        generic_response(code: 200, message: body, content_type: 'text/plain')
      end

      # Internal: Handles a request to the topX JSON API
      #
      # Returns nothing
      def handle_top_request
        size = Util::Utils.suffix_number('/top', @request.path)
        return generic_response({ code: 500, message: 'Invalid request' }) unless size

        controller = Stream::StreamController.instance
        tags       = controller.top_n(size)
        generic_response(code: 200, message: JSON.generate(tags), content_type: 'application/json')
      end

      # Internal: Handles a response generically based on options.
      #
      # opts - Options to set on the generic_response
      #
      # Examples
      #
      #  generic_response(code: 404, message: 'Not Found', content_type: 'text/html')
      #
      # Returns nothing
      def generic_response(opts = {})
        defaults           = {
            code:         404,
            message:      'Endpoint not found',
            content_type: 'text/html'
        }.merge(opts)

        defaults[:message] = File.read(defaults[:file]) unless defaults[:file].nil?

        @response.status       = defaults[:code]
        @response.body         = defaults[:message]
        @response.content_type = defaults[:content_type]
      end

    end
  end
end
