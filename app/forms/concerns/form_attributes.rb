module FormAttributes
  extend ActiveSupport::Concern

  included do
    extend AutoStripAttributes
    class_attribute :attribute_names

    def initialize(*args, **kwargs)
      super(*args, **kwargs)

      default_attrs = self.class.scoped_defaults.values.reduce(&:merge)

      self.class.scoped_attributes.values.flatten.each do |attribute_string|
        next unless send(attribute_string).blank?
        send("#{attribute_string}=", default_attrs&.fetch(attribute_string, nil))
      end
    end
  end

  class_methods do
    def set_attributes_for(model, *attributes, **options)
      if options[:defaults].present?
        scoped_defaults[model] = options[:defaults].compact
      elsif model.respond_to?(:column_defaults)
        scoped_defaults[model] = model.column_defaults
          .compact
          .transform_keys(&:to_sym)
          .slice(*attributes)
      end

      scoped_attributes[model] = attributes

      self.attribute_names = scoped_attributes.values.flatten
      attribute_strings = Attributes.new(attributes).to_s

      attr_accessor(*attribute_strings)

      auto_strip_attributes *attribute_strings, virtual: true
    end

    def before_validation_squish(*attributes)
      auto_strip_attributes *attributes, virtual: true, squish: true
    end

    def scoped_defaults
      @scoped_defaults ||= {}
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
