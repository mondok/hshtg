# Utilities class for helpers and tools
module Hshtg
  class Utils
    class << self
      # Check if Redis is available to use as a cache
      def redis_available?
        gem 'redis'
        true
      rescue Gem::LoadError
        false
      end

      # Load any environment variables from disk
      def load_env_vars
        exists = File.exist?('.env')
        return false unless exists

        File.open('.env', 'r').each_line do |line|
          a = line.chomp("\n").split('=', 2)
          a[1].gsub!(/^"|"$/, '') if ['\'', '"'].include?(a[1][0])
          eval "ENV['#{a[0]}']='#{a[1] || ''}'"
        end
        true
      end
    end
  end
end
