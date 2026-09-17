class ApplicationRecord < ActiveRecord::Base
  include DateAccessible

  self.abstract_class = true

  # Allow counting up to a max number; see https://alexcastano.com/the-hidden-cost-of-the-invisible-queries-in-rails/#how-far-do-you-plan-to-count
  scope :count_greater_than?, ->(n) { limit(n + 1).count > n }

  # Matches ActiveRecord::Enum#enum, which takes the enum name positionally. The old
  # `(**enums)` signature accepted the keyword form (`enum foo: {...}`) that Rails 8.0
  # removed; the positional form used now is valid on both 7.2 and 8.0.
  def self.enum(name, values = nil, **options)
    super

    mapping = defined_enums[name.to_s]
    return if mapping.nil?

    attribute(name) do |subtype|
      subtype = subtype.subtype if ActiveRecord::Enum::EnumType === subtype # rubocop:disable Style/CaseEquality
      EnumTypeWithoutValidValueAssertion.new(name, mapping, subtype)
    end

    validates_inclusion_of name, { in: mapping.keys + mapping.values, allow_blank: true }
  end
end
