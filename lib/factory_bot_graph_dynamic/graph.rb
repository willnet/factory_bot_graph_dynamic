# frozen_string_literal: true

require "json"

module FactoryBotGraphDynamic
  class Graph
    attr_reader :label, :nodes, :edges

    def initialize(label: nil)
      @label = label
      @nodes = []
      @edges = []
    end

    def add_node(node)
      @nodes << node
      node
    end

    def replace_node(node)
      index = @nodes.index { |candidate| candidate.id == node.id }
      index ? @nodes[index] = node : add_node(node)
      node
    end

    def add_edge(edge)
      @edges << edge
      edge
    end

    def to_h
      {
        label: label,
        nodes: nodes.map(&:to_h),
        edges: edges.map(&:to_h)
      }.compact
    end

    def to_json(*args)
      JSON.pretty_generate(to_h, *args)
    end

    def to_mermaid
      lines = ["graph TD"]
      nodes.each do |node|
        lines << %(  #{mermaid_id(node.id)}["#{escape_mermaid(node_label(node))}"])
      end
      edges.each do |edge|
        lines << %(  #{mermaid_id(edge.from)} -->|"#{escape_mermaid(edge_label(edge))}"| #{mermaid_id(edge.to)})
      end
      lines.join("\n")
    end

    private

    def node_label(node)
      parts = [node.factory, node.strategy, *node.traits].compact
      parts.join(" ")
    end

    def edge_label(edge)
      [edge.relation, edge.source].compact.join(" / ")
    end

    def mermaid_id(id)
      "n#{id}"
    end

    def escape_mermaid(value)
      value.to_s.gsub("\\", "\\\\\\").gsub('"', '\"')
    end
  end
end
