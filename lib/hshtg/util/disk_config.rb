require 'yaml'

# Public: Loads config values from file on disk
module Hshtg
  module Util
    class DiskConfig

      # Public: Initialize with file name and existing options
      # If file is not found, ignore it
      #
      # Examples
      #
      #  DiskConfig.new('test.yml')
      def initialize(file_name, opts)
        @config  = YAML.load_file(file_name) if File.exist?(file_name)
        @options = opts
      end

      # Public: Get any configuration values that were in the file
      #
      # returns hash
      def options
        return @options unless @config

        handle_logging
        handle_tag_area
        handle_server_area
        handle_storage_area
        @options
      end

      private

      # Internal: Looks for any logging settings
      #
      # returns nothing
      def handle_logging
        section = @config['logging']
        return unless section
        device                     = section['device']
        @options[:log_device]          = device != 'console' ? device : STDOUT
      end

      # Internal: Looks for any tag-specific settings
      # and sets options
      #
      # returns nothing
      def handle_tag_area
        section = @config['tags']
        return unless section
        ttl                     = section['ttl']
        case_sensitive_matching = section['case_sensitive_matching']
        @options[:ttl]          = ttl if ttl
        @options[:case]         = case_sensitive_matching if case_sensitive_matching
      end

      # Internal: Looks for any server-specific settings
      # and sets options
      #
      # returns nothing
      def handle_server_area
        section = @config['server']
        return unless section
        port                           = section['port']
        automatic_restart              = section['automatic_restart']
        @options[:port]                = port if port
        @options[:automatic_restart]   = automatic_restart if automatic_restart
      end

      # Internal: Looks for any storage-specific settings
      # and sets options
      #
      # returns nothing
      def handle_storage_area
        section = @config['storage']
        return unless section
        storage_type       = section['type']
        @options[:storage] = storage_type == 'redis' ? Storage::RedisStore : Storage::InMemoryStore
      end
    end
  end
end
