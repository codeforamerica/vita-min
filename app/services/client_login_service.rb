class ClientLoginService
  attr_accessor :service_type, :service_class
  SERVICE_TYPES = [:gyr, :ctc]

  def initialize(service_type)
    raise ArgumentError, "Service type must be one of: #{SERVICE_TYPES.join(', ')}" unless SERVICE_TYPES.include? service_type.to_sym

    @service_class = service_type.to_sym == :gyr ? Intake::GyrIntake : Intake::CtcIntake
    # needs to account for also searching for the phone/email in Archived::Intake2021 model (of type gyr intake)
  end

  def clients_for_token(raw_token)
    # Probably needs to happen twice, once for service_class Intake::GyrIntake and once again for Archived::Intake2021

    # these might have multiple email addresses
    to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
    emails = to_addresses.map { |to| to.split(",") }.flatten(1)
    email_intake_matches = service_class.accessible_intakes.where(email_address: emails)
    spouse_email_intake_matches = service_class.accessible_intakes.where(spouse_email_address: emails)
    phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)
    phone_intake_matches = service_class.accessible_intakes.where(sms_phone_number: phone_numbers)
    intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

    Client.where(intake: intake_matches).uniq
  end

  def can_login_by_email_verification?(email_address)
    service_class.accessible_intakes.where(email_address: email_address).or(service_class.accessible_intakes.where(spouse_email_address: email_address)).exists?
  end

  def can_login_by_sms_verification?(sms_phone_number)
    service_class.accessible_intakes.where(sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").exists?
  end
end
