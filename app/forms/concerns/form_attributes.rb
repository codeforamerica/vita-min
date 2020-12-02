module FormAttributes
  extend ActiveSupport::Concern

  included do
    extend AutoStripAttributes
    class_attribute :attribute_names
  end

  class_methods do
    def set_attributes_for(model, *attributes)
      scoped_attributes[model] = attributes
      self.attribute_names = scoped_attributes.values.flatten
      attribute_strings = Attributes.new(attributes).to_s

      attr_accessor(*attribute_strings)
      auto_strip_attributes *attribute_strings, virtual: true
    end

    def scoped_attributes
      @scoped_attributes ||= {}
    end

    def existing_attributes(model)
      if model.present?
        HashWithIndifferentAccess.new(model.attributes)
      else
        {}
      end
    end
  end

  def attributes_for(model)
    self.class.scoped_attributes[model].reduce({}) do |hash, attribute_name|
      hash[attribute_name] = send(attribute_name)
      hash
    end
  end
end
