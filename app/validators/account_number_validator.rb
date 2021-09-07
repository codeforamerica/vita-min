class AccountNumberValidator < ActiveModel::EachValidator
  REGEX = /\A\d{0,17}\z/

  def validate_each(record, attr_name, value)
    unless value&.match?(REGEX)
      record.errors.add(attr_name, I18n.t("validators.account_number"))
    end
  end
end
