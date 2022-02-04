class ClientLoginService
  attr_accessor :service_type
  SERVICE_TYPES = [:gyr, :ctc]

  def initialize(service_type)
    raise ArgumentError, "Service type must be one of: #{SERVICE_TYPES.join(', ')}" unless SERVICE_TYPES.include? service_type.to_sym

    @service_type = service_type
  end

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
    (Client.where(intake: intake_matches) + Client.by_raw_login_token(raw_token)).uniq
  end

  def can_login_by_email_verification?(email_address, service_type: :gyr)
    accessible_intakes.where(email_address: email_address).or(accessible_intakes.where(spouse_email_address: email_address)).exists?
  end

  def can_login_by_sms_verification?(sms_phone_number, service_type: :gyr)
    accessible_intakes.where(sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").exists?
  end

  def accessible_intakes
    service_type.to_sym == :gyr ? self.class.accessible_gyr_intakes : self.class.accessible_ctc_intakes
  end

  private

  def self.accessible_gyr_intakes
    online_consented = Intake::GyrIntake.joins(:tax_returns).where({ tax_returns: { service_type: "online_intake" } }).where(primary_consented_to_service: "yes")
    drop_off = Intake::GyrIntake.joins(:tax_returns).where({ tax_returns: { service_type: "drop_off" } })
    online_consented.or(drop_off)
  end

  def self.accessible_ctc_intakes
    sms_verified = Intake::CtcIntake.where.not(sms_phone_number_verified_at: nil)
    email_verified = Intake::CtcIntake.where.not(email_address_verified_at: nil)
    navigator_verified = Intake::CtcIntake.where.not(navigator_has_verified_client_identity: nil)

    sms_verified.or(email_verified).or(navigator_verified)
  end

  def self.has_ctc_duplicate?(intake)
    has_dupe = false
    accessible_intakes = accessible_ctc_intakes.where.not(id: intake.id)
    if intake.email_address.present?
      has_dupe = accessible_intakes.where(email_address: intake.email_address).exists?
    end
    if intake.sms_phone_number.present? && !has_dupe
      has_dupe = accessible_intakes.where(sms_phone_number: intake.sms_phone_number).exists?
    end
    has_dupe
  end
end
