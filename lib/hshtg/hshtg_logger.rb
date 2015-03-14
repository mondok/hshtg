require 'logger'

# Logging module that wraps standard logger
# and prints to STDOUT.
# TODO add ability to log to a file
module Hshtg
	module HshtgLogger
		def self.included(base)
			base.extend(ClassMethods)
		end

		module ClassMethods
			def logger
				@_logger ||= Logger.new(STDOUT)
				@_logger.level = Logger::INFO
				@_logger
			end
		end

		def logger
			self.class.logger
		end
	end
end
