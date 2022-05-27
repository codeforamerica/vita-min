class AlphanumericValidator < ActiveModel::EachValidator
  REGEX = /^[A-Za-z0-9]+$/

  def validate_each(record, attr_name, value)
    unless value&.match?(REGEX)
      record.errors.add(attr_name, I18n.t("validators.alphanumeric"))
    end
  end
end
