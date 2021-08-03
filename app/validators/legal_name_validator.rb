class LegalNameValidator < ActiveModel::EachValidator
  NAME_REGEXP = /\A[A-Za-z\s.'-]+\z/.freeze

  def validate_each(record, attr_name, value)
    return if value.blank?

    unless I18n.transliterate(value).match? NAME_REGEXP
      record.errors[attr_name] << I18n.t('validators.legal_name')
    end
  end
end