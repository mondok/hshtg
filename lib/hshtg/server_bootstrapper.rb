require 'webrick'

# Server class for handling all signaling as well as boostrapping the stream
# HashtagEndpoint is the actual server itself, while
# StreamController is what manages the thread and bringing in the new hashtags.
module Hshtg
  module ServerBootstrapper
    include Hshtg::HshtgLogger

    class << self
      def stop
        @server.shutdown if @server
      end

      def start
        # make sure all the keys are set
        validate_keys

        options = update_config_options

        # create a new server
        @server = WEBrick::HTTPServer.new(Port: options[:port])

        # start singleton stream controller
        @controller = Hshtg::StreamController.instance.start

        # mount the REST server on webrick
        @server.mount '/', Hshtg::HttpEndpoint

        trap_signals

        @server.start
      end

      private

      # Trap any UNIX signals that are sent to the API
      def trap_signals
        # kill
        trap('INT') do
          puts('INT received')
          @server.shutdown
        end

        # kill
        trap('TERM') do
          puts('TERM received')
          @server.shutdown
        end

        # graceful
        trap('QUIT') do
          puts('QUIT received')
          @controller.stop
          @server.shutdown
        end

        # reset things
        trap('HUP') do
          puts('HUP received')
          @controller.reset
        end
      end

      # Make sure all the API keys are valid before continuing
      def validate_keys
        return if Hshtg::Configuration.is_valid?
        logger.error('==== Please set all environment variables before starting the server ====')
        exit
      end

      # Get configuration options from arguments
      def update_config_options
        options = OptsParser.options(ARGV)
        Hshtg::Configuration.tag_time_to_live_in_seconds = options[:ttl]
        Hshtg::Configuration.case_sensitive_matching = options[:case]
        Hshtg::Configuration.hashtag_storage_class = options[:storage]
        current_config = Hshtg::Configuration.to_a
        current_config << "Port: #{options[:port]}"
        logger.info(current_config.join(', '))
        options
      end
    end
  end
end
