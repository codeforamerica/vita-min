class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Allow counting up to a max number; see https://alexcastano.com/the-hidden-cost-of-the-invisible-queries-in-rails/#how-far-do-you-plan-to-count
  scope :count_greater_than?, ->(n) { limit(n + 1).count > n }

  def self.enum_with_validation(**enums)
    enum **enums

    enums.each do |enum_name, _|
      enum_names_and_values = defined_enums[enum_name.to_s]
      next if enum_names_and_values.nil?
      attribute(enum_name, :enum) do |subtype|
        LiberalEnumType.new(enum_name, public_send(enum_name.to_s.pluralize), subtype)
      end

      validates_inclusion_of enum_name, { in: enum_names_and_values.keys.map(&:to_s) + enum_names_and_values.values }
    end
  end

  def self.validates_enum(*enums)
    enums.each do |enum_attribute|
      define_method(:"#{enum_attribute}=") do |value|
        enum_info = self.class.send("#{enum_attribute.to_s.pluralize}")
        if (enum_info.values + enum_info.keys).include?(value)
          super value
        else
          self.instance_variable_set(:"@not_valid_#{enum_attribute}_type", true)
        end
      end

      validate do
        if self.instance_variable_get(:"@not_valid_#{enum_attribute}_type")
          errors.add(enum_attribute, "Not a valid #{enum_attribute} type}")
        end
      end
    end
  end
end
