require 'optparse'

# Public: Options Parser class to get config values from command line
module Hshtg
  module Util
    class OptsParser
      class << self
        # Public: parse the ARGV options
        def options(args)
          # handle the port options and help
          options = { port: 3000, case: false, automatic_restart: true, ttl: 60, storage: Storage::InMemoryStore, log_device: STDOUT }
          parser  = OptionParser.new do |opts|
            opts.banner = 'Usage: ruby hshtg.rb [options]'

            # Check if a file should be used to load defaults
            opts.on('-f', '--file [settings.yml]', 'use a yaml file to load settings - if other command line values are set, they will override the file values') do |f|
              file_name = f || 'settings.yml'
              options   = DiskConfig.new(file_name, options).options
            end

            # Check if case sensitivity should be set for grouping hash tags
            opts.on('-c', '--case [0]', 'case sensitivity (0 or 1), 1 for sensitive which means tags will be grouped separately if they are cased differently') do |c|
              val = c.to_i
              unless val.between?(0, 1)
                puts 'Case must be 0 or 1'
                puts opts
                exit
              end
              options[:case] = val != 0
            end

            # Check if server should automatically restart on failure
            opts.on('-r', '--restart [1]', 'automatic restart (0 or 1), 1 for restart on failure') do |r|
              val = r.to_i
              unless val.between?(0, 1)
                puts 'Automatic restart must be 0 or 1'
                puts opts
                exit
              end
              options[:automatic_restart] = val == 1
            end

            # Optionally use Redis as a cache store
            opts.on('-s', '--store [in-memory]', 'type of backend storage for storing hashtags (in-memory or redis)') do |storage|
              if storage.downcase == 'redis'
                if Utils.gem_available?('redis')
                  options[:storage] = Storage::RedisStore
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

            # Instead of every 60 seconds, use a custom set time
            opts.on('-l', '--logging [console]', 'where to output logs (console or filename)') do |device|
              options[:log_device] = device != 'console' ? device : STDOUT
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
end
