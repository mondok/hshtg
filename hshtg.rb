#!/usr/bin/env ruby

require_relative 'lib/hshtg'
require_relative 'lib/hshtg/util/user_setup'

# Check for .env file
Hshtg::Util::Utils.load_env_vars

# If it's being run without testing
if __FILE__== $PROGRAM_NAME
  if Hshtg::Util::Configuration.is_valid?
    Hshtg::Http::ServerBootstrapper.start
  else
    user_setup = Hshtg::Util::UserSetup.new(Hshtg::Util::Configuration.env_variable_names)
    user_setup.try_help
  end
end
