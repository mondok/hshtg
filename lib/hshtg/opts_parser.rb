require 'optparse'

# Options Parser class to get config values from command line
module Hshtg
  class OptsParser
    class << self
      def options(args)
        # handle the port options and help
        options = { port: 3000, case: false, ttl: 60, storage: Hshtg::Storage::InMemoryStore }
        parser  = OptionParser.new do |opts|
          opts.banner = 'Usage: hshtg.rb [options]'

          # Check if a file should be used to load defaults
          opts.on('-f', '--file [settings.yml]', 'use a yaml file to load settings - if other command line values are set, they will override the file values') do |f|
            file_name = f || 'settings.yml'
            options = Hshtg::DiskConfig.new(file_name, options).options
          end

          # Check if case sensitivity should be set for grouping hash tags
          opts.on('-c', '--case [0]', 'case sensitivity (0 or 1), 1 for sensitive which means tags will be grouped separately if they are cased differently') do |c|
            val = c.to_i
            if val < 0 || val > 1
              puts 'Case must be 0 or 1'
              puts opts
              exit
            end
            options[:case] = val != 0
          end

          # Optionally use Redis as a cache store
          opts.on('-s', '--store [in-memory]', 'type of backend storage for storing hashtags (in-memory or redis)') do |storage|
            if storage.downcase == 'redis'
              if Hshtg::Utils.redis_available?
                options[:storage] = Hshtg::Storage::RedisStore
              else
                puts 'Redis is not available because the gem is not installed'
                puts opts
                exit
              end
            end
          end

          # Instead of every 60 seconds, use a custom set time
          opts.on('-t', '--ttl [60]', 'tags time to live before they are not counted') do |t|
            if t.to_i == 0
              puts 'TTL must be numeric and greater than zero'
              puts opts
              exit
            end
            options[:ttl] = t.to_i
          end

          # Listen on a different port
          opts.on('-p', '--port [3000]', 'server port to listen on') do |port|
            if port.to_i == 0
              puts 'Port must be numeric and greater than zero'
              puts opts
              exit
            end
            options[:port] = port.to_i
          end

          # Show the help
          opts.on('-h', '--help', 'displays help') do
            puts opts
            exit
          end
        end
        parser.parse!(args)
        options
      end
    end
  end
end
