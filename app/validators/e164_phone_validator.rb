class E164PhoneValidator < ActiveModel::EachValidator
  # The E.164 validator assumes the data has normalized into a +1NNNNNNNNNN format, aka E.164.
  # This may occur in a form, or in a before_validation hook, etc.
  def validate_each(record, attr_name, value)
    return if value&.valid_encoding? && value =~ /\A\+1\d{10}\z/ && Phony.plausible?(value)

    record.errors[attr_name] << I18n.t("errors.attributes.phone_number.invalid")
  end
end
