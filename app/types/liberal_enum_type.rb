class LiberalEnumType < ActiveRecord::Type::Enum
  def assert_valid_value(_value); end
end
