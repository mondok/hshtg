#!/usr/bin/env ruby

require_relative 'lib/hshtg'

# Check for .env file
Hshtg::Utils.load_env_vars

if __FILE__== $PROGRAM_NAME
  if Hshtg::Configuration.is_valid?
    Hshtg::ServerBootstrapper.start
  else
    Hshtg::Utils.no_keys_error_message
  end
end
