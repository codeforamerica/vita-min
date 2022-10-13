module Ctc
  module W2s
    class W2Form < Form
      include FormAttributes

      attr_reader :w2

      def initialize(w2 = nil, params = {})
        @w2 = w2
        super(params)
      end

      def save
        @w2.assign_attributes(attributes_for(:w2).merge(extra_attributes))
        @w2.save!
      end

      def extra_attributes
        {}
      end

      def self.from_w2(w2)
        attribute_keys = Attributes.new(scoped_attributes[:w2]).to_sym
        new(w2, existing_attributes(w2, attribute_keys))
      end

      def self.existing_attributes(model, attribute_keys)
        HashWithIndifferentAccess[(attribute_keys || []).map { |k| [k, model.send(k)] }]
      end
    end
  end
end
