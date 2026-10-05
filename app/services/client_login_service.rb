class ClientLoginService
  attr_accessor :intake_classes

  def initialize(service_type)
    @service_type = service_type
    @intake_classes = (
      if service_type == :statefile
        StateFile::StateInformationService.state_intake_classes
      else
        [MultiTenantService.new(service_type).intake_model]
      end
    )
  end

  def login_records_for_token(raw_token)
    if [:gyr, :ctc].include? @service_type
      clients_for_token(raw_token)
    else
      intakes_for_token(raw_token) # state file
    end
  end

  def intakes_for_token(raw_token)
    @intake_classes.map{ |c| intake_of_type_for_token(c, raw_token) }.detect(&:present?) || []
  end

  def intake_of_type_for_token(intake_class, raw_token)
    # these might have multiple email addresses
    to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
    emails = to_addresses.map { |to| to.split(",") }.flatten(1)
    email_intake_matches = intake_class.accessible_intakes.where(email_address: emails)
    if intake_class.column_names.include? "spouse_email_address"
      spouse_email_intake_matches = intake_class.accessible_intakes.where(spouse_email_address: emails)
      email_intake_matches = email_intake_matches.or(spouse_email_intake_matches)
    end
    phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)
    phone_intake_matches = intake_class.accessible_intakes.where(sms_phone_number: phone_numbers)
    email_intake_matches.or(phone_intake_matches)
  end

  def clients_for_token(raw_token)
    Client.where(intake: intakes_for_token(raw_token)).uniq
  end

  def can_login_by_email_verification?(email_address)
    service_class = @intake_classes.detect do |service_class|
      intakes = service_class.accessible_intakes.where(email_address: email_address)
      if service_class == Intake::CtcIntake || service_class == Intake::GyrIntake
        intakes = intakes.or(service_class.accessible_intakes.where(spouse_email_address: email_address))
      end
      intakes.exists?
    end
    service_class.present?
  end

  def can_login_by_sms_verification?(sms_phone_number)
    service_class = @intake_classes.detect do |service_class|
      intakes = service_class.accessible_intakes
      intakes = (
        if service_class == Intake::CtcIntake || service_class == Intake::GyrIntake
          intakes.where(sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes")
        else
          intakes.where(phone_number: sms_phone_number)
        end
      )
      intakes.exists?
    end
    service_class.present?
  end
end
