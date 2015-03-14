# Utilities class for helpers and tools
module Hshtg
  module Utils
    module_function

    # Strip any prefixed text and return a positive number
    # Return nil if not a number or negative
    def suffix_number(prefix_to_strip, text)
      return nil if text.nil?
      val = text.downcase.gsub(prefix_to_strip.downcase, '')
      val.to_i if positive_integer(val)
    end

    # Check if string is positive integer
    def positive_integer(value)
      /\A\d+\z/.match(value) && value.to_i > 0
    end

    # Check if Redis is available to use as a cache
    def gem_available?(name)
      gem name
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

    def no_keys_error_message
      puts "ERROR:  Please ensure all the API environment variables are set either in a .env file or your profile.  The variables are:"
      puts
      Hshtg::Configuration.env_variable_names.each do |c|
        puts "  #{c}=[YOUR #{c}]"
      end
      puts
      puts "If you haven't yet generated your keys, you can create an App and get keys at https://apps.twitter.com/."
      puts "There is also a sample.env file in the app root which you can use as an example to set keys local to the application."
    end
  end
end
