class ApplicationRecord < ActiveRecord::Base
  include DateAccessible

  self.abstract_class = true

  # Allow counting up to a max number; see https://alexcastano.com/the-hidden-cost-of-the-invisible-queries-in-rails/#how-far-do-you-plan-to-count
  scope :count_greater_than?, ->(n) { limit(n + 1).count > n }

  def self.enum(**enums)
    if ENV['NEXT']
      enum_name, enum_values = enums.shift

      enums[:prefix] = enums.delete(:_prefix)

      super enum_name, enum_values, **enums
      self.new_enum_api(enum_name, **enums)
    else
      super
      self.old_enum_api(**enums)
    end
  end

  def self.old_enum_api(**enums)
    enums.each do |enum_name, _|
      mapping = defined_enums[enum_name.to_s]
      next if mapping.nil?
      attribute(enum_name) do |subtype|
        subtype = subtype.subtype if ActiveRecord::Enum::EnumType === subtype # rubocop:disable Style/CaseEquality
        EnumTypeWithoutValidValueAssertion.new(enum_name, mapping, subtype)
      end

      validates_inclusion_of enum_name, { in: mapping.keys + mapping.values, allow_blank: true }
    end
  end

  def self.new_enum_api(enum_name, **enums)
    mapping = defined_enums[enum_name.to_s]
    return if mapping.nil?
    attribute(enum_name) do |subtype|
      subtype = subtype.subtype if ActiveRecord::Enum::EnumType === subtype # rubocop:disable Style/CaseEquality
      EnumTypeWithoutValidValueAssertion.new(enum_name, mapping, subtype)
    end

    validates_inclusion_of enum_name, { in: mapping.keys + mapping.values, allow_blank: true }
  end
end
