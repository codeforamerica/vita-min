class IrsCityTypeValidator < ActiveModel::EachValidator
  REGEX = /\A([A-Za-z] ?)*[A-Za-z]\z/
  MAX_LENGTH = 22

  def validate_each(record, attr_name, value)
    return if value.nil?

    unless value =~ REGEX
      record.errors.add(attr_name, I18n.t("validators.irs_city"))
    end

    unless value.length <= MAX_LENGTH
      record.errors.add(attr_name, I18n.t("errors.messages.too_long", count: MAX_LENGTH))
    end
  end
end
