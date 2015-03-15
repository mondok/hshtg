require 'logger'

# Public: Logging module that wraps standard logger
# and prints to STDOUT or whatever is set in configuration.
module Hshtg
  module Util
    module HshtgLogger
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def logger
          @_logger       ||= Logger.new(Configuration.log_capture_device)
          @_logger.level = Logger::INFO
          @_logger
        end
      end

      def logger
        self.class.logger
      end
    end
  end
end
