#!/usr/bin/env ruby

require_relative 'lib/hshtg'
require_relative 'lib/hshtg/user_setup'

# Check for .env file
Hshtg::Utils.load_env_vars

if __FILE__== $PROGRAM_NAME
  if Hshtg::Configuration.is_valid?
    Hshtg::ServerBootstrapper.start
  else
    user_setup = Hshtg::UserSetup.new(Hshtg::Configuration.env_variable_names)
    user_setup.try_help
  end
end
