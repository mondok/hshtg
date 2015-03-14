require 'yaml'

# Loads config values from file on disk
module Hshtg
  class DiskConfig
    # Initialize with file name and existing options
    # If file is not found, ignore it
    def initialize(file_name, opts)
      @config = YAML.load_file(file_name) if File.exist?(file_name)
      @options = opts
    end

    # Get any configuration values that were in the file
    def options
      return @options unless @config

      handle_tag_area
      handle_server_area
      handle_storage_area
      @options
    end

    private

    def handle_tag_area
      section = @config['tags']
      return unless section
      ttl = section['ttl']
      case_sensitive_matching = section['case_sensitive_matching']
      @options[:ttl] = ttl if ttl
      @options[:case] = case_sensitive_matching if case_sensitive_matching
    end

    def handle_server_area
      section = @config['server']
      return unless section
      port = section['port']
      @options[:port] = port if port
    end

    def handle_storage_area
      section = @config['storage']
      return unless section
      storage_type = section['type']
      @options[:storage] = storage_type == 'redis' ? Hshtg::Storage::RedisStore : Hshtg::Storage::InMemoryStore
    end
  end
end