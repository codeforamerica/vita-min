class ClientLoginsService
  class << self
    def issue_email_token(email_address)
      raw_token, hashed_token = Devise.token_generator.generate(EmailAccessToken, :token)
      EmailAccessToken.create!(token: hashed_token, email_address: email_address)
      raw_token
    end

    def issue_text_message_token(sms_phone_number)
      raw_token, hashed_token = Devise.token_generator.generate(TextMessageAccessToken, :token)
      TextMessageAccessToken.create!(token: hashed_token, sms_phone_number: sms_phone_number)
      raw_token
    end

    def request_email_login(email_address:, visitor_id:, locale:)
      email_match_exists =  Intake.where(email_address: email_address).or(
        Intake.where(spouse_email_address: email_address)
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
      if Intake.where(sms_phone_number: sms_phone_number).exists?
        create_text_message_login(sms_phone_number: sms_phone_number, visitor_id: visitor_id, locale: locale)
      elsif Intake.where(phone_number: sms_phone_number).exists?
        # make a system note on all matching clients
        # count as an incoming interaction
      else
        home_url = Rails.application.routes.url_helpers.root_url(locale: locale)
        TwilioService.send_text_message(
          to: sms_phone_number,
          body: I18n.t("client_logins.no_account_found_sms", locale: locale, home_url: home_url)
        )
      end
    end

    def create_email_login(email_address:, visitor_id:, locale:)
      raw_token, hashed_token = Devise.token_generator.generate(EmailAccessToken, :token)
      access_token = EmailAccessToken.create!(token: hashed_token, email_address: email_address)
      EmailLoginRequest.create!(email_access_token: access_token, visitor_id: visitor_id)
      ClientLoginRequestMailer.with(
        to: email_address,
        raw_token: raw_token,
        locale: locale
      ).login_email.deliver_later
    end

    def create_text_message_login(sms_phone_number:, visitor_id:, locale:)
      raw_token, hashed_token = Devise.token_generator.generate(TextMessageAccessToken, :token)
      access_token = TextMessageAccessToken.create!(token: hashed_token, sms_phone_number: sms_phone_number)
      TextMessageLoginRequest.create!(text_message_access_token: access_token, visitor_id: visitor_id)
      login_token_link = Rails.application.routes.url_helpers.portal_client_login_url(locale: locale, id: raw_token)
      text_message_body = I18n.t("client_logins.login_sms", locale: locale, login_link: login_token_link)
      TwilioService.send_text_message(to: sms_phone_number, body: text_message_body)
    end

    def clients_for_token(raw_token)
      # these might have multiple email addresses
      to_addresses = EmailAccessToken.by_raw_token(raw_token).pluck(:email_address)
      emails = to_addresses.map { |to| to.split(",") }.flatten(1)
      email_intake_matches = Intake.where(email_address: emails)
      spouse_email_intake_matches = Intake.where(spouse_email_address: emails)
      phone_numbers = TextMessageAccessToken.by_raw_token(raw_token).pluck(:sms_phone_number)
      phone_intake_matches = Intake.where(sms_phone_number: phone_numbers)
      intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

      Client.where(intake: intake_matches).or(Client.by_raw_login_token(raw_token))
    end
  end
end
