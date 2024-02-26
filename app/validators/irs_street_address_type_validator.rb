class IrsStreetAddressTypeValidator < ActiveModel::EachValidator
  attr_accessor :maximum
  ADDRESS_REGEX = /\A[A-Za-z0-9]( ?[A-Za-z0-9\- \/])*\z/

  def initialize(options)
    super
    @maximum = options.fetch(:maximum, 35)
  end

  def validate_each(record, attr_name, value)
    return if value.nil? || value == ''

    unless value =~ ADDRESS_REGEX
      record.errors.add(attr_name, I18n.t("validators.irs_street_address"))
    end

    unless @maximum.nil?
      ActiveModel::Validations::LengthValidator.new(maximum: @maximum, attributes: attributes).validate_each(record, attr_name, value)
    end
  end
end
