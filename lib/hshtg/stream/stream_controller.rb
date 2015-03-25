require 'singleton'

# Public: Singleton controller class that wraps the StreamParser.  This class
# gives the API server access to StreamParser so it can
# stop and reset the firehose.
# We need a singleton here because with Webrick, each new request
# creates a new instance and we don't want to stop and start the thread.
module Hshtg
  module Stream
    class StreamController
      include Util::HshtgLogger
      include Singleton

      # Pubilc: StreamParser used for reading text from HTTP
      attr_writer :stream_parser

      # Public: timestamp for when processing started
      attr_reader :started_at

      # Public: create new StreamController
      #
      # opts - Options to initialize with
      #   hash_store_class - class to use for storage
      #   tag_ttl - integer for how long extract tags should live
      #   case_sensitive - boolean specifying case sensitivity
      #
      # Examples
      #
      #   StreamController.new(
      #                         hash_store_class: Hshtg::Storage:InMemory
      #                         tag_ttl: 60
      #                         case_sensitive: false
      #                       )
      def initialize(opts = {})
        @config = {
            hash_store_class: Util::Configuration.hashtag_storage_class,
            tag_ttl:          Util::Configuration.tag_time_to_live_in_seconds,
            case_sensitive:   Util::Configuration.case_sensitive_matching
        }.merge(opts)

        logger.info('StreamController initializing')
        hash_klass     = @config[:hash_store_class]
        @stream_parser = StreamParser.new(hash_klass.new)
        @started_at    = DateTime.now
        @watch_thread  = Thread.new { start_watchdog! }
      end

      # Public: Request the top X current hashtags.
      #
      # n - integer number of tags to return
      #
      # Examples
      #
      #  StreamController.instance.top_n(5)
      #
      # returns array of HashtagResult
      def top_n(n = 10)
        logger.info("Top #{n} tags requested")
        tags = @stream_parser.hash_store.fresh_tags(@config[:tag_ttl])
        HashtagExtractor.extract_tags!(tags, n, @config[:case_sensitive])
      end

      # Public: Start processing
      #
      # returns instance of StreamController
      def start
        logger.info('StreamController starting')
        @stream_parser.begin_read
        self
      end

      # Public: Stop processing gracefully
      #
      # returns instance of StreamController
      def stop
        logger.info('StreamController attempting to stop gracefully')
        stop_watchdog!
        @stream_parser.shutdown!
        self
      end

      # Public: Reset the counter and the stream entirely
      #
      # returns instance of StreamController
      def reset
        logger.info('StreamController resetting stream and thread')
        @stream_parser.reset!
        self
      end

      private
      
      # Internal: Stops watchdog thread

      # returns nothing
      def stop_watchdog!
        @watch_thread.exit if @watch_thread
      end

      # Internal: Watches the run thread to make sure it's still alive

      # returns nothing
      def start_watchdog!
        while true
          sleep 10
          logger.info('Watchdog')
          @stream_parser.begin_read unless @stream_parser.alive?
        end
      end
    end
  end
end
