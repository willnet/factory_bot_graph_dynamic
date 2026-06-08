# frozen_string_literal: true

module FactoryBotGraphDynamic
  Edge = Struct.new(
    :from,
    :to,
    :relation,
    :source,
    :strategy,
    :traits,
    :overrides,
    :location,
    keyword_init: true
  ) do
    def to_h
      {
        from: from,
        to: to,
        relation: relation,
        source: source,
        strategy: strategy,
        traits: traits,
        overrides: overrides,
        location: location
      }.compact
    end
  end
end
