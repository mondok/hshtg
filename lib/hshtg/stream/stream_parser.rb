require 'oauth'
require 'net/http'
require 'json'

# Public: The StreamParser manages the threading and the
# Twitter firehose of content.
# It opens a single thread and "drinks from the firehose."
# It also manages the eviction of old tags
# to keep memory usage down to a minimum.
module Hshtg
  module Stream
    class StreamParser
      include Util::HshtgLogger

      # Public: Hashtag storage container
      attr_accessor :hash_store

      # Public: initialize StreamParser and
      # accept hash_store option in case we want
      # to use a backend and not in-memory storage
      #
      # Examples
      #
      #  StreamParser.new(Hshtg::Storage::InMemoryStore)
      def initialize(hash_store)
        # Initialize the thread to nil
        @main_thread     = nil

        # Reset is used in the situation that a HUP signal is sent
        @reset           = false
        @hash_store      = hash_store
        @request_builder = Http::RequestBuilder.new
      end

      # Public: Opens the Twitter firehose
      #
      # returns nothing
      def begin_read
        logger.info('Open the firehose')
        open_thread
      end

      # Public: Resets the firehose
      #
      # returns nothing
      def reset!
        logger.info('Reset the firehose')
        reset_stream
      end

      # Public: Shut. Down. Everything.
      #
      # returns nothing
      def shutdown!
        logger.info('Shutting down the Firehose')
        reset_stream(true)
      end

      private

      # Internal: Add tags to storage layer
      #
      # returns array of Hashtag
      def add_tags(tags)
        @hash_store.add_tags(tags)
      end

      # Internal: Evicts old tags based on a time constraint
      #
      # returns array of Hashtag
      def evict_old_tags
        @hash_store.evict_old_tags(Util::Configuration.tag_time_to_live_in_seconds)
      end

      # Internal: This fires our worker thread.  It sets main_thread
      # and eventually opens the firehose.
      #
      # returns nothing
      def open_thread
        cleanup_thread
        @reset       = false
        @main_thread = Thread.new { thread }
      end

      # Internal: Thread wrapper that runs the worker
      #
      # returns nothing
      def thread
        process_stream
      rescue Interrupt, TypeError
        logger.warn('Closing thread')
      rescue StandardError => e
        logger.fatal(e)
      end

      # Internal: If the current thread is alive, we want to
      # gracefully exit it.
      #
      # returns nothing
      def cleanup_thread
        return unless @main_thread
        @main_thread.terminate
        @main_thread = nil
      end

      # Internal: Recycle the thread from zero.  We need to first stop the
      # current thread gracefully, then create it again.
      # Notice we wait to clear the hash_tags array until after
      # we have confirmation of the thread wrapping up.
      # If the stop_processing boolean is true, we're looking to not
      # start processing again.
      #
      # stop_processing - boolean determining whether processing should reset
      #
      # returns nothing
      def reset_stream(stop_processing = false)
        @reset = true
        cleanup_thread
        @hash_store.clear
        begin_read unless stop_processing
      end

      # Internal: Worker logic - opens the stream and reads from it
      #
      # returns nothing
      def process_stream
        http, request = @request_builder.build_request
        http.request request do |response|
          logger.info('Firehose opened successfully')
          response.read_body do |body|
            begin
              # If reset is true, we need to finish up
              if @reset
                logger.info('Closing the stream')
                http.finish
                return
              end

              # Pluck out all the hash tags
              tags = HashtagExtractor.hash_tags_from_tweet(body)
              evict_old_tags
              add_tags(tags)

            rescue StandardError => e
              logger.error("Bad parse call: #{e} - #{e.backtrace}")
            end
          end
        end
      end
    end
  end
end
