# frozen_string_literal: true

module FactoryBotGraphDynamic
  class Configuration
    attr_accessor :capture_backtrace, :max_depth, :include_overrides

    def initialize
      @capture_backtrace = true
      @max_depth = nil
      @include_overrides = true
    end
  end
end
