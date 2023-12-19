class ClientLoginService
  attr_accessor :service_class

  def initialize(service_type)
    @service_class = MultiTenantService.new(service_type).intake_model
  end

  def intakes_for_token(raw_token)
    # these might have multiple email addresses
    to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
    emails = to_addresses.map { |to| to.split(",") }.flatten(1)
    email_intake_matches = service_class.accessible_intakes.where(email_address: emails)
    if service_class.column_names.include? "spouse_email_address"
      spouse_email_intake_matches = service_class.accessible_intakes.where(spouse_email_address: emails)
      email_intake_matches = email_intake_matches.or(spouse_email_intake_matches)
    end
    phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)
    phone_intake_matches = service_class.accessible_intakes.where(sms_phone_number: phone_numbers)
    email_intake_matches.or(phone_intake_matches)
  end

  def clients_for_token(raw_token)
    Client.where(intake: intakes_for_token(raw_token)).uniq
  end

  def can_login_by_email_verification?(email_address)
    service_class.accessible_intakes.where(email_address: email_address).or(service_class.accessible_intakes.where(spouse_email_address: email_address)).exists?
  end

  def can_login_by_sms_verification?(sms_phone_number)
    if service_class == Intake::CtcIntake || service_class == Intake::GyrIntake
      return service_class.accessible_intakes.where(sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").exists?
    elsif service_class == StateFileAzIntake || service_class == StateFileNyIntake
      return service_class.can_be_authenticated.where(phone_number: sms_phone_number).exists?
    end
  end
end
