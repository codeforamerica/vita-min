class Archived::Intake::CtcIntake2021 < Archived::Intake2021
  attribute :eip1_amount_received, :money
  attribute :eip2_amount_received, :money
  attribute :primary_prior_year_agi_amount, :money
  attribute :spouse_prior_year_agi_amount, :money

  attr_encrypted :primary_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :primary_ip_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_ip_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :primary_signature_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :spouse_signature_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  enum had_dependents: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_dependents
  enum eip1_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip1_entry_method
  enum eip2_entry_method: { unfilled: 0, calculated_amount: 1, did_not_receive: 2, manual_entry: 3 }, _prefix: :eip2_entry_method
  enum eip1_and_2_amount_received_confidence: { unfilled: 0, sure: 1, unsure: 2 }, _prefix: :eip1_and_2_amount_received_confidence
  enum filed_prior_tax_year: { unfilled: 0, filed_full: 1, filed_non_filer: 2, did_not_file: 3 }, _prefix: :filed_prior_tax_year
  enum spouse_filed_prior_tax_year: { unfilled: 0, filed_full_joint: 1, filed_non_filer_joint: 2, filed_full_separate: 3, filed_non_filer_separate: 4, did_not_file: 5 }, _prefix: :spouse_filed_prior_tax_year
  enum had_reportable_income: { yes: 1, no: 2 }, _prefix: :had_reportable_income
  enum spouse_can_be_claimed_as_dependent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_can_be_claimed_as_dependent
  enum spouse_active_armed_forces: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_active_armed_forces
  enum cannot_claim_me_as_a_dependent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :cannot_claim_me_as_a_dependent
  enum primary_active_armed_forces: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_active_armed_forces
  enum has_primary_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_primary_ip_pin
  enum has_spouse_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_spouse_ip_pin
  enum consented_to_legal: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_legal

  has_one :bank_account, inverse_of: :intake, dependent: :destroy, class_name: 'Archived::BankAccount2021', foreign_key: 'archived_intakes_2021_id'
  accepts_nested_attributes_for :bank_account

  before_validation do
    attributes_to_change = self.changes_to_save.keys
    name_attributes = ["primary_first_name", "primary_last_name", "spouse_first_name", "spouse_last_name"]

    (attributes_to_change & name_attributes).each do |attribute|
      if self.attributes[attribute].present?
        new_value = self.attributes[attribute].split(/\s/).filter { |str| !str.empty? }.join(" ")
        self.assign_attributes(attribute => new_value)
      end
    end
  end

  PHOTO_ID_TYPES = {
    drivers_license: {
      display_name: "Drivers License",
      field_name: :with_drivers_license_photo_id
    },
    passport: {
      display_name: "US Passport",
      field_name: :with_passport_photo_id
    },
    other_state: {
      display_name: "Other State ID",
      field_name: :with_other_state_photo_id
    },
    vita_approved: {
      display_name: "Identification approved by my VITA site",
      field_name: :with_vita_approved_photo_id
    }
  }

  TAXPAYER_ID_TYPES = {
    social_security: {
      display_name: "Social Security card",
      field_name: :with_social_security_taxpayer_id
    },
    itin: {
      display_name: "Individual Taxpayer ID Number (ITIN) letter",
      field_name: :with_itin_taxpayer_id
    },
    vita_approved: {
      display_name: "Identification approved by my VITA site",
      field_name: :with_vita_approved_taxpayer_id
    }
  }

  def document_types_definitely_needed
    []
  end

  def is_ctc?
    true
  end

  def default_tax_return
    tax_returns.find_by(year: TaxReturn.current_tax_year)
  end

  # we dont currently ask for preferred name in the onboarding flow, so let's use primary first name to keep the app working for MVP
  def preferred_name
    read_attribute(:preferred_name) || primary_first_name
  end

  def photo_id_display_names
    names = []
    PHOTO_ID_TYPES.each do |_, type|
      if self.send(type[:field_name])
        names << type[:display_name]
      end
    end
    names.join(', ')
  end

  def taxpayer_id_display_names
    names = []
    TAXPAYER_ID_TYPES.each do |_, type|
      if self.send(type[:field_name])
        names << type[:display_name]
      end
    end
    names.join(', ')
  end

  def any_ip_pins?
    primary_ip_pin.present? || spouse_ip_pin.present? || dependents.any? { |d| d.ip_pin.present? }
  end

  def filing_jointly?
    client.tax_returns.last.filing_status_married_filing_jointly?
  end
end
