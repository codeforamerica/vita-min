class IrsBusinessNameTypeValidator < ActiveModel::EachValidator
  BUSINESS_REGEX = /\A(([A-Za-z0-9#[-]()]|&|') ?)*([A-Za-z0-9#[-]()]|&|')\z/

  def validate_each(record, attr_name, value)
    unless value =~ BUSINESS_REGEX
      record.errors.add(attr_name, I18n.t("validators.irs_business_name"))
    end

    ActiveModel::Validations::LengthValidator.new(maximum: 75, attributes: attributes).validate_each(record, attr_name, value)
  end
end
