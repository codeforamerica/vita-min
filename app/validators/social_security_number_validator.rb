class SocialSecurityNumberValidator < ActiveModel::EachValidator
  SSN_REGEX = /\A(?!(000|666|9))\d{3}-?(?!00)\d{2}-?(?!0000)\d{4}\Z/

  def validate_each(record, attr_name, value)
    unless value =~ SSN_REGEX
      record.errors[attr_name] << I18n.t("validators.ssn")
    end
  end
end
