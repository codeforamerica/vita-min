class UsOrPuertoRicoZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /\A\d{5}\z/

  def validate_each(record, attr_name, value)
    us_zip_code = ZipCodes.has_key?(value)
    puerto_rico_zip_code = value&.starts_with?('006') || value&.starts_with?('007') || value&.starts_with?('009')
    unless value =~ ZIP_CODE_REGEX && (us_zip_code || puerto_rico_zip_code)
      record.errors.add(attr_name, I18n.t("validators.zip"))
    end
  end
end
