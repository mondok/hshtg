# Public: Utilities class for helpers and tools
module Hshtg
  module Util
    module Utils
      module_function

      # Public: Strip any prefixed text and return a positive number
      #
      # prefix_to_strip - string prefix to strip
      # text - string to strip from
      #
      # Examples
      #
      #  Utils.suffix_number('/top', '/top10') => returns 10
      #
      # returns integer if positive number, else nil
      def suffix_number(prefix_to_strip, text)
        return nil if text.nil?
        val = text.downcase.gsub(prefix_to_strip.downcase, '')
        val.to_i if positive_integer(val)
      end

      # Public: Check if string is positive integer
      #
      # value - string of text that might be a number
      #
      # Examples
      #
      #  Utils.positive_integer("100")
      #
      # returns boolean
      def positive_integer(value)
        /\A\d+\z/.match(value) && value.to_i > 0
      end

      # Public: Check if gem is available
      #
      # name - string name of gem
      #
      # Examples
      #
      #  Utils.gem_available?('redis')
      #
      # returns boolean
      def gem_available?(name)
        gem name
        true
      rescue Gem::LoadError
        false
      end

      # Public: Load any environment variables from disk
      #
      # returns nothing
      def load_env_vars
        exists = File.exist?('.env')
        return false unless exists
        lines = []
        File.open('.env', 'r').each_line do |line|
          lines << line
        end
        parse_env_vars(lines)
        true
      end

      # Public: Load array of strings into ENV variables
      #
      # Examples
      #  parse_env_vars('TAG1=test', 'TAG2=test1')
      #
      # returns integer for number of vars set
      def parse_env_vars(*env_vars)
        success = 0
        env_vars.flatten.each do |env|
          a = env.chomp("\n").split('=', 2) if env
          if a && a.length == 2
            a[1].gsub!(/^"|"$/, '') if ['\'', '"'].include?(a[1][0])
            eval "ENV['#{a[0]}']='#{a[1] || ''}'"
            success+=1
          end
        end
        success
      end
    end
  end
end
