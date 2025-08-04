class Graph::Graph
  @graph_registry = []

  class << self
    attr_accessor :graph_registry

    def module_name = self.to_s.underscore.split("/").last.to_sym

    def inherited(subclass)
      super(subclass)
      subclass.graph_registry = []
    end

    def inputs
      prepare_fact_objects
        .values
        .flat_map(&:values)
        .flat_map(&:inputs)
        .select { |f| f.present? }
        .flat_map(&:keys)
    end

    def fact(name, &def_proc)
      superclass.graph_registry << { module_name:, name:, def_proc: }
    end
    alias_method :constant, :fact

    def evaluate(input)
      graph = prepare_fact_objects

      graph.transform_values do |fact_hash| # Iterate module hash returning fact hash of all facts in module
        fact_hash.transform_values do |f| # Convert Fact instances to their resolved values
          f.call(input)
        end
      end
    end

    def prepare_fact_objects
      graph = {}

      self.graph_registry.map do |kwargs|
        kwargs in { module_name:, name: }

        fact = Graph::Fact.new(graph:, **kwargs)

        graph[module_name] ||= {}
        graph[module_name][name] = fact
      end

      graph
    end
  end
end
