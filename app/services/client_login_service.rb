class ClientLoginService
  attr_accessor :service_type, :service_class
  SERVICE_TYPES = [:gyr, :ctc]

  def initialize(service_type)
    raise ArgumentError, "Service type must be one of: #{SERVICE_TYPES.join(', ')}" unless SERVICE_TYPES.include? service_type.to_sym

    @service_type = service_type
    @service_class = service_type == :gyr ? Intake::GyrIntake : Intake::CtcIntake
  end

  def clients_for_token(raw_token)
    # these might have multiple email addresses
    to_addresses = EmailAccessToken.lookup(raw_token).pluck(:email_address)
    emails = to_addresses.map { |to| to.split(",") }.flatten(1)
    email_intake_matches = service_class.accessible_intakes.where(email_address: emails)
    spouse_email_intake_matches = service_class.accessible_intakes.where(spouse_email_address: emails)
    phone_numbers = TextMessageAccessToken.lookup(raw_token).pluck(:sms_phone_number)
    phone_intake_matches = service_class.accessible_intakes.where(sms_phone_number: phone_numbers)
    intake_matches = email_intake_matches.or(spouse_email_intake_matches).or(phone_intake_matches)

    # Client.by_raw_login_token supports login links generated from mid-Jan through early March 2021.
    (Client.where(intake: intake_matches) + Client.by_raw_login_token(raw_token)).uniq
  end

  def can_login_by_email_verification?(email_address)
    service_class.accessible_intakes.where(email_address: email_address).or(accessible_intakes.where(spouse_email_address: email_address)).exists?
  end

  def can_login_by_sms_verification?(sms_phone_number)
    service_class.accessible_intakes.where(sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").exists?
  end

  # def self.ctc_duplicate?(intake)
  #   has_dupe = false
  #   if intake.email_address.present?
  #     has_dupe = DeduplicationService.duplicates(intake, email_address, from_scope: service_class.accessible_intakes).exists?
  #   end
  #   if intake.sms_phone_number.present? && !has_dupe
  #     has_dupe = DeduplicationService.duplicates(intake, sms_phone_number, from_scope: service_class.accessible_intakes).exists?
  #   end
  #   has_dupe
  # end

  def self.gyr_duplicate?(intake)
    return false unless intake.hashed_primary_ssn.present?

    DeduplificationService.duplicates(intake, :hashed_primary_ssn, service_class.accessible_intakes).exists?
  end
end
