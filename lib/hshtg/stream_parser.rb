require 'oauth'
require 'net/http'
require 'json'

# The StreamParser manages the threading and the
# Twitter firehose of content.
# It opens a single thread and "drinks from the firehose."
# It also manages the eviction of old tags
# to keep memory usage down to a minimum.
module Hshtg
	class StreamParser
		include Hshtg::HshtgLogger

		# stored tags
		attr_accessor :hash_store

		# accept hash_store option in case we want to use a backend and not in-memory storage
		def initialize(hash_store)
			# Initialize the thread to nil
			@main_thread = nil

			# Reset is used in the situation that a HUP signal is sent
			@reset = false
			@hash_store = hash_store
			@request_builder = Hshtg::RequestBuilder.new
		end

		# Opens the Twitter firehose
		def begin_read
			logger.info('Open the firehose')
			open_thread
		end

		# Resets the firehose
		def reset!
			logger.info('Reset the firehose')
			reset_stream
		end

		# Shut. Down. Everything.
		def shutdown!
			logger.info('Shutting down the Firehose')
			reset_stream(true)
		end

		private

		# Add tags to storage layer
		def add_tags(tags)
			@hash_store.add_tags(tags)
		end

		# Evicts old tags based on a time constraint
		def evict_old_tags
			@hash_store.evict_old_tags(Hshtg::Configuration.tag_time_to_live_in_seconds)
		end

		# This fires our worker thread.  It sets main_thread
		# and eventually opens the firehose.
		def open_thread
			cleanup_thread
			@reset = false
			@main_thread = Thread.new { thread }
		end

		# Thread wrapper that runs the worker
		def thread
			process_stream
		rescue Interrupt, TypeError
			logger.warn('Closing thread')
		rescue StandardError => e
			logger.fatal(e)
		end

		# If the current thread is alive, we want to
		# gracefully exit it.
		def cleanup_thread
			return unless @main_thread
			@main_thread.terminate
			@main_thread = nil
		end

		# Recycle the thread from zero.  We need to first stop the
		# current thread gracefully, then create it again.
		# Notice we wait to clear the hash_tags array until after
		# we have confirmation of the thread wrapping up.
		# If the stop_processing boolean is true, we're looking to not
		# start processing again.
		def reset_stream(stop_processing = false)
			@reset = true
			cleanup_thread
			@hash_store.clear
			begin_read unless stop_processing
		end

		# Worker logic - opens the stream and reads from it
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
						tags = Hshtg::HashtagExtractor.hash_tags_from_tweet(body)
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
