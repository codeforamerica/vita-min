class GyrNumericalityValidator < ActiveModel::Validations::NumericalityValidator
  PG_INT_MAX = 2**31 - 1

  def initialize(options)
    options[:less_than] ||= PG_INT_MAX
    super
  end

  def validate_each(record, attr_name, value)
    super(record, attr_name, clean_value(value))
  end

  private

  def clean_value(value)
    if value.kind_of?(String)
      value.gsub(/[^0-9]/, '')
    else
      value
    end
  end
end
