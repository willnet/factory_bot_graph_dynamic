# frozen_string_literal: true

require "factory_bot_graph_dynamic"
require "factory_bot"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }

  config.before do
    FactoryBot.reload
  end
end
