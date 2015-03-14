require 'singleton'

# Singleton controller class that wraps the StreamParser.  This class
# gives the API server access to StreamParser so it can
# stop and reset the firehose.
# We need a singleton here because with Webrick, each new request
# creates a new instance and we don't want to stop and start the thread.
module Hshtg
	class StreamController
		include Hshtg::HshtgLogger
		include Singleton

		attr_writer :stream_parser
		attr_reader :started_at

		# Initializer for StreamController
		# Options are:
		#   hash_store_class
		#   tag_ttl
		#   case_sensitive
		def initialize(opts = {})
			@config = {
				hash_store_class: Hshtg::Configuration.storage_class,
				tag_ttl: Hshtg::Configuration.tag_time_to_live_in_seconds,
				case_sensitive: Hshtg::Configuration.case_sensitive_matching
			}.merge(opts)

			logger.info('StreamController initializing')
			hash_klass = @config[:hash_store_class]
			@stream_parser = Hshtg::StreamParser.new(hash_klass.new)
			@started_at = DateTime.now
		end

		# Request the top ten current hashtags
		def top_n(n = 10)
			logger.info("Top #{n} tags requested")
			tags = @stream_parser.hash_store.fresh_tags(@config[:tag_ttl])
			Hshtg::HashtagExtractor.extract_tags!(tags, n, @config[:case_sensitive])
		end

		# Start processing
		def start
			logger.info('StreamController starting')
			@stream_parser.begin_read
			self
		end

		# Stop processing gracefully
		def stop
			logger.info('StreamController attempting to stop gracefully')
			@stream_parser.shutdown!
			self
		end

		# Reset the counter and the stream entirely
		def reset
			logger.info('StreamController resetting stream and thread')
			@stream_parser.reset!
			self
		end
	end
end
