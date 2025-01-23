# == Schema Information
#
# Table name: state_file_md_intakes
#
#  id                                         :bigint           not null, primary key
#  account_holder_first_name                  :string
#  account_holder_last_name                   :string
#  account_holder_middle_initial              :string
#  account_holder_suffix                      :string
#  account_number                             :string
#  account_type                               :integer          default("unfilled"), not null
#  authorize_sharing_of_health_insurance_info :integer          default("unfilled"), not null
#  bank_authorization_confirmed               :integer          default("unfilled"), not null
#  city                                       :string
#  confirmed_permanent_address                :integer          default("unfilled"), not null
#  consented_to_sms_terms                     :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions          :integer          default("unfilled"), not null
#  contact_preference                         :integer          default("unfilled"), not null
#  current_sign_in_at                         :datetime
#  current_sign_in_ip                         :inet
#  current_step                               :string
#  date_electronic_withdrawal                 :date
#  df_data_import_succeeded_at                :datetime
#  df_data_imported_at                        :datetime
#  eligibility_filing_status_mfj              :integer          default("unfilled"), not null
#  eligibility_home_different_areas           :integer          default("unfilled"), not null
#  eligibility_homebuyer_withdrawal           :integer          default("unfilled"), not null
#  eligibility_homebuyer_withdrawal_mfj       :integer          default("unfilled"), not null
#  eligibility_lived_in_state                 :integer          default("unfilled"), not null
#  eligibility_out_of_state_income            :integer          default("unfilled"), not null
#  email_address                              :citext
#  email_address_verified_at                  :datetime
#  email_notification_opt_in                  :integer          default("unfilled"), not null
#  failed_attempts                            :integer          default(0), not null
#  federal_return_status                      :string
#  had_hh_member_without_health_insurance     :integer          default("unfilled"), not null
#  has_joint_account_holder                   :integer          default("unfilled"), not null
#  hashed_ssn                                 :string
#  joint_account_holder_first_name            :string
#  joint_account_holder_last_name             :string
#  joint_account_holder_middle_initial        :string
#  joint_account_holder_suffix                :string
#  last_sign_in_at                            :datetime
#  last_sign_in_ip                            :inet
#  locale                                     :string           default("en")
#  locked_at                                  :datetime
#  message_tracker                            :jsonb
#  payment_or_deposit_type                    :integer          default("unfilled"), not null
#  permanent_address_outside_md               :integer          default("unfilled"), not null
#  permanent_apartment                        :string
#  permanent_city                             :string
#  permanent_street                           :string
#  permanent_zip                              :string
#  phone_number                               :string
#  phone_number_verified_at                   :datetime
#  political_subdivision                      :string
#  primary_birth_date                         :date
#  primary_did_not_have_health_insurance      :integer          default("unfilled"), not null
#  primary_disabled                           :integer          default("unfilled"), not null
#  primary_esigned                            :integer          default("unfilled"), not null
#  primary_esigned_at                         :datetime
#  primary_first_name                         :string
#  primary_last_name                          :string
#  primary_middle_initial                     :string
#  primary_signature                          :string
#  primary_signature_pin                      :text
#  primary_ssn                                :string
#  primary_student_loan_interest_ded_amount   :decimal(12, 2)   default(0.0), not null
#  primary_suffix                             :string
#  raw_direct_file_data                       :text
#  raw_direct_file_intake_data                :jsonb
#  referrer                                   :string
#  residence_county                           :string
#  routing_number                             :string
#  secondary_disabled                         :integer          default("unfilled"), not null
#  sign_in_count                              :integer          default(0), not null
#  sms_notification_opt_in                    :integer          default("unfilled"), not null
#  source                                     :string
#  spouse_birth_date                          :date
#  spouse_did_not_have_health_insurance       :integer          default("unfilled"), not null
#  spouse_esigned                             :integer          default("unfilled"), not null
#  spouse_esigned_at                          :datetime
#  spouse_first_name                          :string
#  spouse_last_name                           :string
#  spouse_middle_initial                      :string
#  spouse_signature_pin                       :text
#  spouse_ssn                                 :string
#  spouse_student_loan_interest_ded_amount    :decimal(12, 2)   default(0.0), not null
#  spouse_suffix                              :string
#  street_address                             :string
#  subdivision_code                           :string
#  unfinished_intake_ids                      :text             default([]), is an Array
#  unsubscribed_from_email                    :boolean          default(FALSE), not null
#  withdraw_amount                            :decimal(12, 2)
#  zip_code                                   :string
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  federal_submission_id                      :string
#  primary_state_id_id                        :bigint
#  spouse_state_id_id                         :bigint
#  visitor_id                                 :string
#
# Indexes
#
#  index_state_file_md_intakes_on_email_address        (email_address)
#  index_state_file_md_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_md_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_md_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
class StateFileMdIntake < StateFileBaseIntake
  include MdResidenceCountyConcern
  encrypts :account_number, :routing_number, :raw_direct_file_data, :raw_direct_file_intake_data

  enum eligibility_lived_in_state: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_lived_in_state
  enum eligibility_out_of_state_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_out_of_state_income
  enum eligibility_filing_status_mfj: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_filing_status_mfj
  enum eligibility_homebuyer_withdrawal: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_homebuyer_withdrawal
  enum eligibility_homebuyer_withdrawal_mfj: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_homebuyer_withdrawal_mfj
  enum eligibility_home_different_areas: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_home_different_areas
  enum confirmed_permanent_address: { unfilled: 0, yes: 1, no: 2 }, _prefix: :confirmed_permanent_address
  enum permanent_address_outside_md: { unfilled: 0, yes: 1, no: 2 }, _prefix: :permanent_address_outside_md
  enum had_hh_member_without_health_insurance: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :had_hh_member_without_health_insurance
  enum authorize_sharing_of_health_insurance_info: { unfilled: 0, yes: 1, no: 2}, _prefix: :authorize_sharing_of_health_insurance_info
  enum primary_did_not_have_health_insurance: { unfilled: 0, yes: 1, no: 2}, _prefix: :primary_did_not_have_health_insurance
  enum spouse_did_not_have_health_insurance: { unfilled: 0, yes: 1, no: 2}, _prefix: :spouse_did_not_have_health_insurance
  enum bank_authorization_confirmed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :bank_authorization_confirmed
  enum has_joint_account_holder: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_joint_account_holder
  enum primary_disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_disabled
  enum secondary_disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :secondary_disabled

  def disqualifying_df_data_reason
    w2_states = direct_file_data.parsed_xml.css('W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd')
    return :has_out_of_state_w2 if w2_states.any? do |state|
      (state.text || '').upcase != state_code.upcase
    end
  end

  def disqualifying_eligibility_rules
    # eligibility_filing_status_mfj is not strictly a disqualifier and just leads us to other questions
    {
      eligibility_homebuyer_withdrawal_mfj: "yes",
      eligibility_homebuyer_withdrawal: "yes",
      eligibility_home_different_areas: "yes",
      permanent_address_outside_md: "yes",
    }
  end

  def ask_for_signature_pin?
    true
  end

  def calculate_age(dob, inclusive_of_jan_1)
    # MD never calculates age at the end of the year using Jan 1 inclusive
    super(dob, inclusive_of_jan_1: false)
  end

  def sanitize_bank_details
    if (payment_or_deposit_type || "").to_sym != :direct_deposit
      self.account_type = "unfilled"
      self.routing_number = nil
      self.account_number = nil
      self.withdraw_amount = nil
      self.date_electronic_withdrawal = nil
      self.account_holder_first_name = nil
      self.account_holder_middle_initial = nil
      self.account_holder_last_name = nil
      self.account_holder_suffix = nil
      self.joint_account_holder_first_name = nil
      self.joint_account_holder_middle_initial = nil
      self.joint_account_holder_last_name = nil
      self.joint_account_holder_suffix = nil
      self.has_joint_account_holder = "unfilled"
      self.bank_authorization_confirmed = "unfilled"
    end
  end

  def filing_status
    {
      1 => :single,
      2 => :married_filing_jointly,
      3 => :married_filing_separately,
      4 => :head_of_household,
      5 => :qualifying_widow,
      6 => :dependent,
    }[direct_file_data&.filing_status]
  end

  def has_dependent_without_health_insurance?
    dependents.any? do |dependent|
      dependent.md_did_not_have_health_insurance_yes?
    end
  end

  def filing_status_dependent?
    filing_status == :dependent
  end

  def address
    if confirmed_permanent_address_yes?
      result = "#{self.direct_file_data.mailing_street}"
      result += " #{self.direct_file_data.mailing_apartment}" if self.direct_file_data.mailing_apartment.present?
      result += ", #{self.direct_file_data.mailing_city}, #{self.direct_file_data.mailing_state} #{self.direct_file_data.mailing_zip}"
      result
    else
      apt = self.permanent_apartment.present? ? " #{self.permanent_apartment}" : ""
      "#{self.permanent_street}#{apt}, #{self.permanent_city} MD, #{self.permanent_zip}"
    end
  end

  def extract_apartment_from_mailing_street?
    true
  end

  def city_name_length_20?
    true
  end

  def allows_refund_amount_in_xml?
    false
  end
end
