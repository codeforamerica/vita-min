class IndividualTaxpayerIdentificationNumberValidator < ActiveModel::EachValidator
  ITIN_REGEX = /\A(?=(9))\d{3}-?([7]\d|8[0-8]|9([0-2]|[4-9]))-?\d{4}\Z/

  def validate_each(record, attr_name, value)
    unless value =~ ITIN_REGEX
      record.errors[attr_name] << I18n.t("validators.itin")
    end
  end
end
