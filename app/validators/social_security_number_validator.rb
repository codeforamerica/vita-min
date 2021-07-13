class SocialSecurityNumberValidator < ActiveModel::EachValidator
  REAL_SSN_REGEX = /\A(?!(000|666|9))\d{3}-?(?!00)\d{2}-?(?!0000)\d{4}\Z/ # Real SSNS cannot have 00 in 4th and 5th position
  LOOSE_SSN_REGEX = /\A(?!(000|666|9))\d{3}-?\d{2}-?(?!0000)\d{4}\Z/

  def validate_each(record, attr_name, value)
    regex = Rails.env.production? ? REAL_SSN_REGEX : LOOSE_SSN_REGEX
    unless value =~ regex
      record.errors[attr_name] << I18n.t("validators.ssn")
    end
  end
end
