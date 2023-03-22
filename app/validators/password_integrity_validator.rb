# frozen_string_literal: true
require 'zxcvbn'
class PasswordIntegrityValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return if record.admin?

    password_test = Zxcvbn.test(value, [record.email, record.phone_number, record.name])

    # Scoring of the test is a range of 0 - 4
    #   0: too guessable: risky password. (guesses < 10^3)
    #   1: very guessable: protection from throttled online attacks. (guesses < 10^6)
    #   2: somewhat guessable: protection from unthrottled online attacks. (guesses < 10^8)
    #   3: safely unguessable: moderate protection from offline slow-hash scenario. (guesses < 10^10)
    #   4: very unguessable: strong protection from offline slow-hash scenario. (guesses >= 10^10)
    # (from https://github.com/dropbox/zxcvbn#usage)

    # NOTE: Add note of feedback from `password_test.feedback`?
    record.errors.add(attr_name, I18n.t("errors.attributes.password.insecure")) if password_test.score <= 2
    record.errors.add(attr_name, I18n.t("errors.attributes.password.incorrect_size")) unless User.PASSWORD_LENGTH.member?(value.length)
  end
end
