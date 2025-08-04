class Graph::Fact
  attr_accessor :name, :module_name, :resolver, :dependencies, :inputs, :graph, :errors

  def initialize(name:, module_name:, graph:, def_proc:)
    @name = name
    @module_name = module_name
    @dependencies = {}
    @inputs = []
    @graph = graph
    @errors = {
      fact_bad_inputs: [],
      fact_dependency_unmet: Hash.new { |h, key| h[key] = [] }
    }

    @resolver = instance_eval(&def_proc)
  end

  def dependency(fact, from: nil)
    if from.nil?
      from = module_name
    end

    dependencies[fact] = from
  end

  def dependency_facts
    dependencies.reduce({}) do |result_hash, values|
      fact_name, module_name = values
      fact = graph[module_name][fact_name]
      raise "#{name}: could not find dependency #{fact_name} in module #{module_name}" if fact.nil?
      result_hash[fact_name] = fact
      result_hash
    end
  end

  def input(name, attribute_name = nil, &validator)
    unless block_given?
      validator = proc { |val| val }
    end

    inputs << Graph::Input.new(name:, attribute_name:, validator:)
  end

  def validate_input(input)
    inputs.each do |input_definition|
      if input_definition.attribute_name
        if input[input_definition.name].is_a?(Array)  # eventually handle different things that might support attribute_name
          input[input_definition.name].each_with_index do |input_value, i|
            input_definition.call(input_value[input_definition.attribute_name])
          rescue Graph::ValidationError
            bad_input = {
              name: :"#{input_definition.name}",
              attribute: :"#{input_definition.attribute_name}",
              index: i
            }
            errors[:fact_bad_inputs] << bad_input
          end
        else
          errors[:fact_bad_inputs] << { name: :"#{input_definition.name}" }
        end
      else
        begin
          input_definition.call(input[input_definition.name])
        rescue Graph::ValidationError
          errors[:fact_bad_inputs] << { name: :"#{input_definition.name}" }
        end
      end
    end
  end

  def call(input)
    return resolver unless resolver.respond_to?(:call)
    return @resolved_value if defined?(@resolved_value)

    data = Graph::DataContainer.new({
      dependencies: dependency_facts.transform_values { |d| d.call(input) },
      input: input.select { |key, value|
        # TODO: Figure out a way to make this lookup constant time
        inputs.any? { |input_definition| input_definition.name == key }
      }
    })

    validate_input(data.data[:input])

    data.data[:dependencies].each do |key, dependency|
      case dependency
      in { fact_dependency_unmet: Hash } | { fact_bad_inputs: Array }
        bad_module = dependency_facts[key].module_name
        errors[:fact_dependency_unmet][bad_module] << key
      else
      end
    end

    if errors[:fact_dependency_unmet].values.any? || errors[:fact_bad_inputs].any?
      return @resolved_value = errors
    end

    begin
      @resolved_value = data.instance_exec(&resolver)
    end
  end
end
