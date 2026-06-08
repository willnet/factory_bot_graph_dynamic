# frozen_string_literal: true

require_relative "factory_bot_graph_dynamic/configuration"
require_relative "factory_bot_graph_dynamic/edge"
require_relative "factory_bot_graph_dynamic/graph"
require_relative "factory_bot_graph_dynamic/node"
require_relative "factory_bot_graph_dynamic/tracer"
require_relative "factory_bot_graph_dynamic/factory_bot_patch"
require_relative "factory_bot_graph_dynamic/version"

module FactoryBotGraphDynamic
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def trace(label = nil, **options, &block)
      raise ArgumentError, "block is required" unless block

      FactoryBotPatch.install!
      Tracer.trace(label: label, configuration: configuration, options: options, &block)
    end
  end
end
