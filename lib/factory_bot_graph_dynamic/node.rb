# frozen_string_literal: true

module FactoryBotGraphDynamic
  Node = Struct.new(
    :id,
    :factory,
    :strategy,
    :traits,
    :overrides,
    :class_name,
    :object_class,
    :record_object_id,
    :location,
    :started_at,
    :finished_at,
    keyword_init: true
  ) do
    def to_h
      {
        id: id,
        factory: factory,
        strategy: strategy,
        traits: traits,
        overrides: overrides,
        class_name: class_name,
        object_class: object_class,
        object_id: record_object_id,
        location: location,
        started_at: started_at,
        finished_at: finished_at
      }.compact
    end
  end
end
