require 'webrick'
require 'json'

# This is the Webrick endpoint for
# serving requests down to the client
module Hshtg
  class HttpEndpoint < WEBrick::HTTPServlet::AbstractServlet
    include Hshtg::HshtgLogger

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

    # Handle HEAD requests for health checks
    def do_HEAD (request, response)
      @request  = request
      @response = response

      logger.info("HEAD #{@request.path} hit")
      controller                 = Hshtg::StreamController.instance
      @response.header['Status'] = controller.nil? ? 'down' : 'up'
    end

    private

    # Handle a HTTP GET on a health check request
    def health_check_request
      controller = Hshtg::StreamController.instance
      if controller
        config_vals = Hshtg::Configuration.to_a.join("\n")
        body        = "status: up\nstarted_at: #{controller.started_at}\n#{config_vals}"
      else
        body = 'status: down'
      end

      generic_response(code: 200, message: body, content_type: 'text/plain')
    end

    # This is if the query comes through successfully
    def handle_top_request
      size = strip_for_top
      return generic_response({ code: 500, message: 'Invalid request' }) unless size
      controller = Hshtg::StreamController.instance
      tags       = controller.top_n(size)
      generic_response(code: 200, message: JSON.generate(tags), content_type: 'application/json')
    end

    # Generic response handler
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

    # Strip out the number from a topX request
    def strip_for_top
      # Dirty gsubbing
      size = @request.path.downcase.gsub('/top', '')
      # Check for positive integer
      return nil if !/\A\d+\z/.match(size) || size.to_i == 0
      return size.to_i
    end
  end
end
