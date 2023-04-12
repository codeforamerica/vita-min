# frozen_string_literal: true
class PasswordStrengthValidator < ActiveModel::EachValidator
  def self.is_strong_enough?(password, record)
    # Scoring of the test is a range of 0 - 4
    #   0: too guessable: risky password. (guesses < 10^3)
    #   1: very guessable: protection from throttled online attacks. (guesses < 10^6)
    #   2: somewhat guessable: protection from unthrottled online attacks. (guesses < 10^8)
    #   3: safely unguessable: moderate protection from offline slow-hash scenario. (guesses < 10^10)
    #   4: very unguessable: strong protection from offline slow-hash scenario. (guesses >= 10^10)
    # (from https://github.com/dropbox/zxcvbn#usage)
    Zxcvbn.test(password, [record.email, record.phone_number, record.name]).score >= 3
  end

  def validate_each(record, attr_name, value)
    return if record.admin?
    return if value.nil? && record.encrypted_password.present?

    record.errors.add(attr_name,I18n.t("errors.attributes.password.too_short")) unless record.password.length >= 10
    record.errors.add(attr_name, I18n.t("errors.attributes.password.insecure")) unless PasswordStrengthValidator.is_strong_enough?(value, record)
  end
end
