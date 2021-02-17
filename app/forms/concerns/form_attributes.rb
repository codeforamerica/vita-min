module FormAttributes
  extend ActiveSupport::Concern

  included do
    extend AutoStripAttributes
    class_attribute :attribute_names
    validate :form_attributes_enum_validation

    def form_attributes_enum_validation
      scoped_attributes = self.class.instance_variable_get(:@scoped_attributes)
      return true if scoped_attributes.nil?

      scoped_attributes.each_key do |model|
        model_class = model.to_s.classify.constantize
        enums = model_class.defined_enums
        scoped_attributes[model].each do |attrib|
          attrib_s = attrib.to_s
          next unless model_class.defined_enums.key?(attrib_s)

          value = send(attrib)
          next if value.nil?

          if !enums[attrib_s].value?(value) && !enums[attrib_s].key?(value)
            errors.add(attrib, I18n.t("forms.errors.invalid_value", value: value))
          end
        end
      end
    end
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
