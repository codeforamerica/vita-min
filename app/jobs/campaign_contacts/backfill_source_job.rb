module CampaignContacts
  class BackfillSourceJob < ApplicationJob
    queue_as :backfills

    EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    E164_REGEX = /\A\+[1-9]\d{1,14}\z/

    def priority
      PRIORITY_LOW
    end

    def valid_email?(email)
      email.present? && email.match?(EMAIL_REGEX)
    end

    def normalize_email(email)
      email = email.to_s.strip.downcase
      valid_email?(email) ? email : nil
    end

    def normalize_phone_number(phone)
      phone = phone.to_s.strip
      return nil if phone.blank?

      normalized = phone.gsub(/[^\d+]/, "")
      normalized.match?(E164_REGEX) ? normalized : nil
    end
  end
end
