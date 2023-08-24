class EnumTypeWithoutValidValueAssertion < ActiveRecord::Enum::EnumType
  def assert_valid_value(value); end
end
