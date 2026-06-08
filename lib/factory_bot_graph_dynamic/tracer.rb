# frozen_string_literal: true

module FactoryBotGraphDynamic
  class Tracer
    THREAD_KEY = :factory_bot_graph_dynamic_tracer

    class << self
      def current
        Thread.current[THREAD_KEY]
      end

      def trace(label:, configuration:, options:)
        tracer = new(label: label, configuration: configuration, options: options)
        previous = current
        Thread.current[THREAD_KEY] = tracer
        yield
        tracer.graph
      ensure
        Thread.current[THREAD_KEY] = previous
      end
    end

    attr_reader :graph

    def initialize(label:, configuration:, options:)
      @graph = Graph.new(label: label)
      @configuration = configuration
      @options = options
      @stack = []
      @edge_context_stack = []
      @association_name_stack = []
      @next_id = 0
    end

    def enter_factory(runner, strategy)
      return yield unless capture_node?

      node = build_started_node(runner, strategy)
      parent = @stack.last
      @graph.add_node(node)
      add_edge(parent, node, strategy) if parent

      @stack.push(node)
      result = yield
      @graph.replace_node(finish_node(node, result))
      result
    ensure
      @stack.pop if node
    end

    def association(factory_name, traits_and_overrides)
      overrides = traits_and_overrides.last.is_a?(Hash) ? traits_and_overrides.last : {}
      traits = traits_and_overrides.last.is_a?(Hash) ? traits_and_overrides[0...-1] : traits_and_overrides
      relation = @association_name_stack.last || (overrides[:factory] ? nil : factory_name)

      @edge_context_stack.push(
        relation: relation,
        source: :association,
        factory: factory_name,
        traits: traits.map(&:to_sym),
        overrides: filtered_overrides(overrides),
        location: caller_location
      )
      yield
    ensure
      @edge_context_stack.pop
    end

    def attribute_association(name)
      @association_name_stack.push(name.to_sym)
      yield
    ensure
      @association_name_stack.pop
    end

    private

    def capture_node?
      !@configuration.max_depth || @stack.size < @configuration.max_depth
    end

    def build_started_node(runner, strategy)
      @next_id += 1
      Node.new(
        id: @next_id,
        factory: ivar(runner, :@name),
        strategy: strategy.to_sym,
        traits: Array(ivar(runner, :@traits)).map(&:to_sym),
        overrides: filtered_overrides(ivar(runner, :@overrides) || {}),
        class_name: build_class_name(runner),
        object_class: nil,
        record_object_id: nil,
        location: caller_location,
        started_at: Process.clock_gettime(Process::CLOCK_MONOTONIC),
        finished_at: nil
      )
    end

    def finish_node(node, result)
      Node.new(
        id: node.id,
        factory: node.factory,
        strategy: node.strategy,
        traits: node.traits,
        overrides: node.overrides,
        class_name: node.class_name,
        object_class: result.class.name,
        record_object_id: result.object_id,
        location: node.location,
        started_at: node.started_at,
        finished_at: Process.clock_gettime(Process::CLOCK_MONOTONIC)
      )
    end

    def add_edge(parent, node, strategy)
      context = @edge_context_stack.last
      @graph.add_edge(
        Edge.new(
          from: parent.id,
          to: node.id,
          relation: context && context[:relation],
          source: context ? context[:source] : :factory_call,
          strategy: strategy.to_sym,
          traits: context ? context[:traits] : node.traits,
          overrides: context ? context[:overrides] : node.overrides,
          location: context && context[:location]
        )
      )
    end

    def build_class_name(runner)
      factory = FactoryBot::Internal.factory_by_name(ivar(runner, :@name))
      factory.build_class.name
    rescue StandardError
      nil
    end

    def ivar(object, name)
      object.instance_variable_get(name)
    end

    def filtered_overrides(overrides)
      return nil unless @configuration.include_overrides

      overrides.reject { |key, _value| key == :strategy }
    end

    def caller_location
      return nil unless @configuration.capture_backtrace

      caller_locations.find do |location|
        !location.path.include?("/factory_bot_graph_dynamic/")
      end&.then { |location| "#{location.path}:#{location.lineno}" }
    end
  end
end
