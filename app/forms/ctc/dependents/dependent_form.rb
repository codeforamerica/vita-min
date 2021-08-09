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
        new(dependent, existing_attributes(dependent).slice(*attribute_keys))
      end
    end
  end
end
