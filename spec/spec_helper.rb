require './hshtg'
require './spec/helpers'

RSpec.configure do |config|
  config.include Helpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # enable so we can include integration tests but optionally run them
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
