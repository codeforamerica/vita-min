class IndividualTaxpayerIdentificationNumberValidator < ActiveModel::EachValidator
  ITIN_REGEX = /\A9\d{2}(5\d|6[0-5]|7\d|8[0-8]|9[0-2]|9[4-9])\d{4}\z/

  def validate_each(record, attr_name, value)
    return if value.blank?

    normalized_value = value.to_s.gsub(/\D/, '')

    unless ITIN_REGEX.match?(normalized_value)
      record.errors.add(attr_name, I18n.t("validators.itin"))
    end
  end
end