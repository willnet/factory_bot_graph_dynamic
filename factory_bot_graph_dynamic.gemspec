# frozen_string_literal: true

require_relative "lib/factory_bot_graph_dynamic/version"

Gem::Specification.new do |spec|
  spec.name = "factory_bot_graph_dynamic"
  spec.version = FactoryBotGraphDynamic::VERSION
  spec.authors = ["Shinichi Maeshima"]
  spec.email = ["netwillnet@gmail.com"]

  spec.summary = "Trace factory_bot execution and render runtime factory graphs"
  spec.description = "Builds a graph from factory_bot definitions that were actually executed."
  spec.homepage = "https://github.com/willnet/factory_bot_graph_dynamic"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir["README.md", "LICENSE", "lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.1"
  spec.add_dependency "factory_bot", ">= 6.0"

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rake", "~> 13.0"
end
