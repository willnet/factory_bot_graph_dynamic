# frozen_string_literal: true

module FactoryBotGraphDynamic
  module FactoryBotPatch
    module FactoryRunnerPatch
      def run(runner_strategy = nil, &block)
        tracer = FactoryBotGraphDynamic::Tracer.current
        return super unless tracer

        strategy = runner_strategy || instance_variable_get(:@strategy)
        tracer.enter_factory(self, strategy) do
          if runner_strategy
            super(runner_strategy, &block)
          else
            super(&block)
          end
        end
      end
    end

    module EvaluatorPatch
      def association(factory_name, *traits_and_overrides)
        tracer = FactoryBotGraphDynamic::Tracer.current
        return super unless tracer

        tracer.association(factory_name, traits_and_overrides) { super }
      end
    end

    module AttributeAssociationPatch
      def to_proc
        original = super
        name = self.name

        lambda do
          tracer = FactoryBotGraphDynamic::Tracer.current
          if tracer
            tracer.attribute_association(name) { instance_exec(&original) }
          else
            instance_exec(&original)
          end
        end
      end
    end

    class << self
      def install!
        return if @installed

        require "factory_bot"

        FactoryBot::FactoryRunner.prepend(FactoryRunnerPatch)
        FactoryBot::Evaluator.prepend(EvaluatorPatch)
        FactoryBot::Attribute::Association.prepend(AttributeAssociationPatch)
        @installed = true
      end
    end
  end
end
