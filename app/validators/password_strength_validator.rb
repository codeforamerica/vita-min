# frozen_string_literal: true
class PasswordStrengthValidator < ActiveModel::EachValidator
  def self.is_strong_enough?(password, record)
    return false if password.nil? || password.length > 256

    Zxcvbn.test(password, [record.email, record.phone_number, record.name]).score >= 3
  end

  def validate_each(record, attr_name, value)
    return if record.admin?
    return if value.nil? && record.encrypted_password.present?

    if !record.password.nil? && record.password.length < Devise.password_length.begin
      record.errors.add(attr_name, I18n.t("errors.attributes.password.too_short", count: Devise.password_length.begin))
    end
    record.errors.add(attr_name, I18n.t("errors.attributes.password.insecure")) unless PasswordStrengthValidator.is_strong_enough?(value, record)
  end
end
