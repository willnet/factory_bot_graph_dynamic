# frozen_string_literal: true

require "spec_helper"

RSpec.describe FactoryBotGraphDynamic do
  class TraceUser
    attr_accessor :name
  end

  class TracePost
    attr_accessor :user
  end

  class TraceComment
    attr_accessor :post
  end

  it "records factories invoked through associations" do
    FactoryBot.define do
      factory :trace_user do
        name { "Jane" }
      end

      factory :trace_post do
        association :user, factory: :trace_user
      end
    end

    graph = described_class.trace do
      FactoryBot.build(:trace_post)
    end

    expect(graph.nodes.map(&:factory)).to eq(%i[trace_post trace_user])
    expect(graph.edges.map(&:source)).to eq([:association])
    expect(graph.edges.first.relation).to eq(:user)
    expect(graph.edges.first.from).to eq(graph.nodes.first.id)
    expect(graph.edges.first.to).to eq(graph.nodes.last.id)
  end

  it "records nested direct factory calls in callbacks" do
    FactoryBot.define do
      factory :trace_comment do
      end

      factory :trace_post do
        after(:build) do
          FactoryBot.build(:trace_comment)
        end
      end
    end

    graph = described_class.trace do
      FactoryBot.build(:trace_post)
    end

    expect(graph.nodes.map(&:factory)).to eq(%i[trace_post trace_comment])
    expect(graph.edges.first.source).to eq(:factory_call)
    expect(graph.edges.first.relation).to be_nil
  end
end
