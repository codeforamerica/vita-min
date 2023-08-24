class AtinValidator < ActiveModel::EachValidator
  ATIN_REGEX = /\A(?=(9))\d{3}-?93-?\d{4}\z/

  def validate_each(record, attr_name, value)
    unless ATIN_REGEX.match?(value)
      record.errors.add(attr_name, I18n.t("validators.atin"))
    end
  end
end