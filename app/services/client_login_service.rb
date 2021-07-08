class ClientLoginService
  class << self
    def clients_for_token(raw_token)
      # these might have multiple email addresses
      to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
      emails = to_addresses.map { |to| to.split(",") }.flatten(1)
      email_intake_matches = accessible_intakes.where(email_address: emails)
      spouse_email_intake_matches = accessible_intakes.where(spouse_email_address: emails)
      phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)
      phone_intake_matches = accessible_intakes.where(sms_phone_number: phone_numbers)
      intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

      # Client.by_raw_login_token supports login links generated from mid-Jan through early March 2021.
      Client.where(intake: intake_matches).or(Client.by_raw_login_token(raw_token))
    end

    def handle_email_request(email_address:, visitor_id:, locale: :en)
      if can_login_by_email_verification?(email_address)
        RequestVerificationCodeEmailJob.perform_later(
          email_address: email_address,
          locale: locale,
          visitor_id: visitor_id,
          service_type: :gyr
        )
      else
        VerificationCodeMailer.no_match_found(
          to: email_address,
          locale: locale,
        ).deliver_later
      end
    end

    def handle_sms_request(phone_number:, visitor_id:, locale: :en)
      if can_login_by_sms_verification?(phone_number)
        RequestVerificationCodeTextMessageJob.perform_later(
          phone_number: phone_number,
          locale: locale,
          visitor_id: visitor_id,
          service_type: :gyr
        )
      else
        home_url = Rails.application.routes.url_helpers.root_url(locale: locale)
        TwilioService.send_text_message(
          to: phone_number,
          body: I18n.t("verification_code_sms.no_match", locale: locale, home_url: home_url)
        )
      end
    end

    def can_login_by_email_verification?(email_address)
      accessible_intakes.where(email_address: email_address).or(accessible_intakes.where(spouse_email_address: email_address)).exists?
    end

    def can_login_by_sms_verification?(sms_phone_number)
      accessible_intakes.where(phone_number: sms_phone_number).or(accessible_intakes.where(sms_phone_number: sms_phone_number)).exists?
    end

    def accessible_intakes
      online_consented = Intake.joins(:tax_returns).where({ tax_returns: { service_type: "online_intake" } }).where(primary_consented_to_service: "yes")
      drop_off = Intake.joins(:tax_returns).where({ tax_returns: { service_type: "drop_off" } })
      online_consented.or(drop_off)
    end
  end
end
