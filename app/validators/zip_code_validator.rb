class ZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /\A\d{5}\z/

  def validate_each(record, attr_name, value)
    unless value =~ ZIP_CODE_REGEX && ZipCodes.has_key?(value)
      record.errors[attr_name] << I18n.t("validators.zip")
    end
  end
end