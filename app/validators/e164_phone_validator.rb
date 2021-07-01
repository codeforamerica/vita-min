class E164PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return if value =~ /\A\+1\d{10}\z/ && Phonelib.valid?(value)

    record.errors[attr_name] << I18n.t("errors.attributes.phone_number.invalid")
  end
end