class IrsCityTypeValidator < ActiveModel::EachValidator
  REGEX = /\A([A-Za-z] ?)*[A-Za-z]\z/

  def validate_each(record, attr_name, value)
    return if value.nil?

    unless value =~ REGEX
      record.errors.add(attr_name, I18n.t("validators.irs_city"))
    end

    ActiveModel::Validations::LengthValidator.new(maximum: 22, attributes: attributes).validate_each(record, attr_name, value)
  end
end
