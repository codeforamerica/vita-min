module Ctc
  module Dependents
    class DependentForm < Form
      include FormAttributes

      attr_reader :dependent

      def initialize(dependent = nil, params = {})
        @dependent = dependent
        super(params)
      end

      def self.from_dependent(dependent)
        attribute_keys = Attributes.new(attribute_names).to_sym
        new(dependent, existing_attributes(dependent, attribute_keys))
      end

      def self.existing_attributes(model, attribute_keys)
        HashWithIndifferentAccess[attribute_keys.map { |k| [k, model.send(k)] }]
      end
    end
  end
end
