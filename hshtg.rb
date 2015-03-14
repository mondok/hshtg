#!/usr/bin/env ruby

require_relative 'lib/hshtg'

# Check for .env file
Hshtg::Utils.load_env_vars

if __FILE__== $PROGRAM_NAME
  if Hshtg::Configuration.is_valid?
    Hshtg::ServerBootstrapper.start
  else
    puts 'Please ensure all environment variables are set.'
  end
end
