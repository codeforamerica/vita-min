class ClientLoginsService
  class << self
    def issue_email_verification_code(email_address)
      existing_tokens = EmailAccessToken.where(email_address: email_address, token_type: "verification_code")
      existing_tokens.order(created_at: :asc).limit(existing_tokens.count - 4).delete_all if existing_tokens.count > 4
      raw_verification_code, hashed_verification_code = VerificationCodeService.generate(email_address)
      DatadogApi.increment("client_logins.verification_codes.email.created")
      [raw_verification_code, EmailAccessToken.create!(
        email_address: email_address,
        token_type: "verification_code",
        token: Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code))]
    end

    def issue_email_token(email_address)
      raw_token, hashed_token = Devise.token_generator.generate(EmailAccessToken, :token)
      EmailAccessToken.create!(token: hashed_token, email_address: email_address)
      raw_token
    end

    def issue_text_message_verification_code(sms_phone_number)
      existing_tokens = TextMessageAccessToken.where(sms_phone_number: sms_phone_number, token_type: "verification_code")
      existing_tokens.order(created_at: :asc).limit(existing_tokens.count - 4).delete_all if existing_tokens.count > 4
      DatadogApi.increment("client_logins.verification_codes.text_message.created")
      raw_verification_code, hashed_verification_code = VerificationCodeService.generate(sms_phone_number)
      [raw_verification_code, TextMessageAccessToken.create!(
        sms_phone_number: sms_phone_number,
        token_type: "verification_code",
        token: Devise.token_generator.digest(TextMessageAccessToken, :token, hashed_verification_code))]
    end

    def issue_text_message_token(sms_phone_number)
      raw_token, hashed_token = Devise.token_generator.generate(TextMessageAccessToken, :token)
      TextMessageAccessToken.create!(token: hashed_token, sms_phone_number: sms_phone_number)
      raw_token
    end

    def request_email_login(email_address:, visitor_id:, locale:)
      email_match_exists = login_accessible_intakes.where(email_address: email_address).or(
        login_accessible_intakes.where(spouse_email_address: email_address)
      ).exists?

      if email_match_exists
        create_email_login(email_address: email_address, visitor_id: visitor_id, locale: locale)
      else
        ClientLoginRequestMailer.with(
          to: email_address,
          locale: locale,
        ).no_match_found.deliver_later
      end
    end

    def request_text_message_login(sms_phone_number:, visitor_id:, locale:)
      if login_accessible_intakes.where(sms_phone_number: sms_phone_number).exists?
        create_text_message_login(sms_phone_number: sms_phone_number, visitor_id: visitor_id, locale: locale)
      else
        home_url = Rails.application.routes.url_helpers.root_url(locale: locale)
        TwilioService.send_text_message(
          to: sms_phone_number,
          body: I18n.t("client_logins.no_account_found_sms", locale: locale, home_url: home_url)
        )
      end
    end

    def create_email_login(email_address:, visitor_id:, locale:)
      verification_code, access_token = issue_email_verification_code(email_address)
      EmailLoginRequest.create!(email_access_token: access_token, visitor_id: visitor_id)
      ClientLoginRequestMailer.with(
        to: email_address,
        verification_code: verification_code,
        locale: locale
      ).login_email.deliver_later
    end

    def create_text_message_login(sms_phone_number:, visitor_id:, locale:)
      verification_code, access_token = issue_text_message_verification_code(sms_phone_number)
      TextMessageLoginRequest.create!(text_message_access_token: access_token, visitor_id: visitor_id)
      text_message_body = I18n.t("client_logins.login_sms", locale: locale, verification_code: verification_code).strip
      TwilioService.send_text_message(to: sms_phone_number, body: text_message_body)
    end

    def clients_for_token(raw_token)
      # these might have multiple email addresses
      to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
      emails = to_addresses.map { |to| to.split(",") }.flatten(1)
      email_intake_matches = login_accessible_intakes.where(email_address: emails)
      spouse_email_intake_matches = login_accessible_intakes.where(spouse_email_address: emails)
      phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)
      phone_intake_matches = login_accessible_intakes.where(sms_phone_number: phone_numbers)
      intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

      # Client.by_raw_login_token supports login links generated from mid-Jan through early March 2021.
      Client.where(intake: intake_matches).or(Client.by_raw_login_token(raw_token))
    end

    private

    def login_accessible_intakes
      online_consented = Intake.joins(:tax_returns).where({ tax_returns: { service_type: "online_intake" } }).where(primary_consented_to_service: "yes")
      drop_off = Intake.joins(:tax_returns).where({ tax_returns: { service_type: "drop_off" } })
      online_consented.or(drop_off)
    end
  end
end
