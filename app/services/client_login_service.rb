class ClientLoginService
  attr_accessor :service_type, :service_class, :backup_service_class
  SERVICE_TYPES = [:gyr, :ctc]

  def initialize(service_type)
    raise ArgumentError, "Service type must be one of: #{SERVICE_TYPES.join(', ')}" unless SERVICE_TYPES.include? service_type.to_sym

    @service_class = service_type.to_sym == :gyr ? Intake::GyrIntake : Intake::CtcIntake
    @backup_service_class = service_type.to_sym == :gyr ? Archived::Intake2021 : Intake::CtcIntake
  end

  def clients_for_token(raw_token)
    to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
    emails = to_addresses.map { |to| to.split(",") }.flatten(1)
    phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)

    email_intake_matches = service_class.where(primary_consented_to_service: true, email_address: emails)
    spouse_email_intake_matches = service_class.where(primary_consented_to_service: true, spouse_email_address: emails)
    phone_intake_matches = service_class.where(primary_consented_to_service: true, sms_phone_number: phone_numbers)

    intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

    if service_class == Intake::CtcIntake
      email_intake_matches = service_class.accessible_intakes.where(email_address: emails)
      spouse_email_intake_matches = service_class.accessible_intakes.where(spouse_email_address: emails)
      phone_intake_matches = service_class.accessible_intakes.where(sms_phone_number: phone_numbers)
      intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

      Client.where(intake: intake_matches).uniq
    elsif (service_class == Intake::GyrIntake && intake_matches.count == 0)
      email_intake_matches = backup_service_class.where(primary_consented_to_service: true, email_address: emails)
      spouse_email_intake_matches = backup_service_class.where(primary_consented_to_service: true, spouse_email_address: emails)
      phone_intake_matches = backup_service_class.where(primary_consented_to_service: true, sms_phone_number: phone_numbers)

      intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

      Client.where(intake: intake_matches).uniq
    else
      Client.where(intake: intake_matches).uniq
    end
  end

  def can_login_by_email_verification?(email_address)
    service_class.accessible_intakes.where(email_address: email_address).or(service_class.accessible_intakes.where(spouse_email_address: email_address)).exists? || backup_service_class.where(primary_consented_to_service: true, email_address: email_address).or(backup_service_class.where(primary_consented_to_service: true, spouse_email_address: email_address)).exists?

    # if backup_service_class
    #   return backup_service_class.where(primary_consented_to_service: true, email_address: email_address).or(backup_service_class.where(primary_consented_to_service: true, spouse_email_address: email_address)).exists?
    # end
  end

  def can_login_by_sms_verification?(sms_phone_number)
    service_class.accessible_intakes.where(sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").exists? || backup_service_class.where(primary_consented_to_service: true, sms_phone_number: sms_phone_number).exists?

    # if backup_service_class
    #   return backup_service_class.where(primary_consented_to_service: true, sms_phone_number: sms_phone_number).exists?
    # end
  end
end
