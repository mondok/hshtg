require 'webrick'

# Public: Server class for handling all signaling as well as boostrapping the stream
# HashtagEndpoint is the actual server itself, while
# StreamController is what manages the thread and bringing in the new hashtags.
module Hshtg
  module Http
    module ServerBootstrapper
      include Util::HshtgLogger

      class << self
        attr_accessor :subscribers

        def subscribe(subscriber)
          @subscribers ||= []
          @subscribers << subscriber if subscriber.respond_to?(:notify)
        end

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

        # Public: Start the WEBrick Server.
        #
        # Examples
        #
        #  ServerBootstrapper.start
        #
        # Returns nothing
        def start
          # make sure all the keys are set
          validate_keys

          options     = update_config_options

          # create a new server
          @server     = WEBrick::HTTPServer.new(Port: options[:port])

          # start singleton stream controller
          @controller = Stream::StreamController.instance.start

          # mount the REST server on webrick
          @server.mount '/', Http::HttpEndpoint

          trap_signals

          logger.info("Server starting with PID #{Process.pid}")

          @server.start
        end

        private

        def notify_subscribers(message)
          if @subscribers
            @subscribers.each do |s|
              s.notify(message)
            end
          end
        end

        # Internal: Traps any UNIX signals and acts accordingly
        #
        # Returns nothing
        def trap_signals
          # kill
          trap('INT') do
            puts('INT received')
            notify_subscribers('INT received')
            @server.shutdown
          end

          # kill
          trap('TERM') do
            puts('TERM received')
            notify_subscribers('TERM received')
            @server.shutdown
          end

          # graceful
          trap('QUIT') do
            puts('QUIT received')
            notify_subscribers('QUIT received')
            @controller.stop
            @server.shutdown
          end

          # reset things
          trap('HUP') do
            puts('HUP received')
            notify_subscribers('HUP received')
            @controller.reset
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
