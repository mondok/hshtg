require 'webrick'

# Public: Server class for handling all signaling as well as boostrapping the stream
# HashtagEndpoint is the actual server itself, while
# StreamController is what manages the thread and bringing in the new hashtags.
module Hshtg
  module Http
    module ServerBootstrapper
      include Util::HshtgLogger

      class << self
        # Public: Stop the WEBrick Server.
        #
        # Examples
        #
        #  ServerBootstrapper.stop
        #
        # Returns nothing
        def stop
          @server.shutdown if @server
        end

        # Public: Gracefully stops server and controller
        #
        # Examples
        #
        #  ServerBootstrapper.stop_soft
        #
        # Returns nothing
        def stop_soft
          @controller.stop if @controller
          stop
        end

        # Public: Reset the controller and index
        #
        # Examples
        #
        #  ServerBootstrapper.reset
        #
        # Returns nothing
        def reset
          @controller.reset if @controller
        end

        # Public: Start the WEBrick Server.
        #
        # controller - StreamController interface for processing text
        #
        # Examples
        #
        #  ServerBootstrapper.start
        #  ServerBootstrapper.start(Stream::StreamController.instance)
        #  ServerBootstrapper.start(MyCustomStreamProcessor.instance)
        #
        # Returns nothing
        def start(controller = Stream::StreamController.instance)
          # make sure all the keys are set
          validate_keys

          options     = update_config_options

          # create a new server
          @server     = WEBrick::HTTPServer.new(Port: options[:port])

          # start singleton stream controller
          @controller = controller.start

          # mount the REST server on webrick
          @server.mount '/', Http::HttpEndpoint

          trap_signals

          logger.info("Server starting with PID #{Process.pid}")

          @server.start
        end

        private

        # Internal: Traps any UNIX signals and acts accordingly
        #
        # Returns nothing
        def trap_signals
          # kill
          trap('INT') do
            puts('INT received')
            stop
          end

          # kill
          trap('TERM') do
            puts('TERM received')
            stop
          end

          # graceful
          trap('QUIT') do
            puts('QUIT received')
            stop_soft
          end

          # reset things
          trap('HUP') do
            puts('HUP received')
            reset
          end
        end

        # Internal: Validates all API keys are set before starting server
        #
        # Returns nothing, exits application if invalid
        def validate_keys
          return if Util::Configuration.is_valid?
          logger.error('==== Please set all environment variables before starting the server ====')
          exit
        end

        # Internal: Updates running config with input keys
        #
        # Returns options hash
        def update_config_options
          options                                         = Util::OptsParser.options(ARGV)
          Util::Configuration.tag_time_to_live_in_seconds = options[:ttl]
          Util::Configuration.case_sensitive_matching     = options[:case]
          Util::Configuration.hashtag_storage_class       = options[:storage]
          Util::Configuration.log_capture_device          = options[:log_device]
          current_config                                  = Util::Configuration.to_a
          current_config << "Port: #{options[:port]}"
          logger.info(current_config.join(', '))
          options
        end
      end
    end
  end
end
