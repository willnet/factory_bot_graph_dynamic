# factory_bot_graph_dynamic

`factory_bot_graph_dynamic` traces factory_bot execution and builds a graph of the
factories that were actually invoked.

## Development status

This gem is under active development. APIs, output formats, and tracing behavior
may change significantly before a stable release.

```ruby
graph = FactoryBotGraphDynamic.trace do
  FactoryBot.create(:order)
end

puts graph.to_mermaid
```

The initial implementation uses a detailed runtime probe based on
`Module#prepend` against factory_bot internals. This gives more accurate parent
and association information than post-hoc notification events alone, while
keeping the public API small.
