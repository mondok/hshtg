# Setup class if user's Twitter keys are not set yet
module Hshtg
  class UserSetup
    # Initialize with any variables we want to set
    def initialize(env_variable_names)
      @envs    = env_variable_names
      @results = {}
    end

    # Try to help guide the user
    def try_help
      if warn
        ask
        write!
      end
    end

    private

    # Warn the user that things aren't setup
    # and ask them if they'd like the server to do the work.
    def warn
      puts 'ERROR:  Please ensure all the API environment variables are set either in a .env file or your profile.  The variables are:'
      puts
      @envs.each do |c|
        puts "  #{c}=[YOUR #{c}]"
      end
      puts
      puts 'If you have not set your keys, but you can easily create an App and get keys at https://apps.twitter.com/.'
      puts 'There is also a sample.env file in the app root which you can use as an example to set keys local to the application.'
      puts 'Would you like to set that up now?  We can guide you. [Yn]'
      val = gets.strip
      val == 'Y'
    end

    # Question them!
    def ask
      @envs.each do |e|
        puts "What is the value of your #{e}?"
        @results[e] = gets.strip
      end
    end

    # Write the .env file to disk
    def write!
      File.open('.env', 'w') do |file|
        @results.each do |key, value|
          file.puts("#{key}=#{value}")
        end
      end
      puts 'The .env file has been written in this directory.  Please restart the server.'
    end
  end
end
