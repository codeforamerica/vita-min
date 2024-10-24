# == Schema Information
#
# Table name: state_file_md_intakes
#
#  id                                   :bigint           not null, primary key
#  account_number                       :string
#  account_type                         :integer          default("unfilled"), not null
#  bank_name                            :string
#  city                                 :string
#  consented_to_terms_and_conditions    :integer          default("unfilled"), not null
#  contact_preference                   :integer          default("unfilled"), not null
#  current_sign_in_at                   :datetime
#  current_sign_in_ip                   :inet
#  current_step                         :string
#  date_electronic_withdrawal           :date
#  df_data_import_failed_at             :datetime
#  df_data_imported_at                  :datetime
#  eligibility_filing_status_mfj        :integer          default("unfilled"), not null
#  eligibility_home_different_areas     :integer          default("unfilled"), not null
#  eligibility_homebuyer_withdrawal     :integer          default("unfilled"), not null
#  eligibility_homebuyer_withdrawal_mfj :integer          default("unfilled"), not null
#  eligibility_lived_in_state           :integer          default("unfilled"), not null
#  eligibility_out_of_state_income      :integer          default("unfilled"), not null
#  email_address                        :citext
#  email_address_verified_at            :datetime
#  failed_attempts                      :integer          default(0), not null
#  federal_return_status                :string
#  hashed_ssn                           :string
#  last_sign_in_at                      :datetime
#  last_sign_in_ip                      :inet
#  locale                               :string           default("en")
#  locked_at                            :datetime
#  message_tracker                      :jsonb
#  payment_or_deposit_type              :integer          default("unfilled"), not null
#  phone_number                         :string
#  phone_number_verified_at             :datetime
#  political_subdivision                :string
#  primary_birth_date                   :date
#  primary_esigned                      :integer          default("unfilled"), not null
#  primary_esigned_at                   :datetime
#  primary_first_name                   :string
#  primary_last_name                    :string
#  primary_middle_initial               :string
#  primary_signature                    :string
#  primary_signature_pin                :text
#  primary_ssn                          :string
#  primary_suffix                       :string
#  raw_direct_file_data                 :text
#  raw_direct_file_intake_data          :jsonb
#  referrer                             :string
#  residence_county                     :string
#  routing_number                       :string
#  sign_in_count                        :integer          default(0), not null
#  source                               :string
#  spouse_birth_date                    :date
#  spouse_esigned                       :integer          default("unfilled"), not null
#  spouse_esigned_at                    :datetime
#  spouse_first_name                    :string
#  spouse_last_name                     :string
#  spouse_middle_initial                :string
#  spouse_signature_pin                 :text
#  spouse_ssn                           :string
#  spouse_suffix                        :string
#  street_address                       :string
#  subdivision_code                     :string
#  unfinished_intake_ids                :text             default([]), is an Array
#  unsubscribed_from_email              :boolean          default(FALSE), not null
#  withdraw_amount                      :decimal(12, 2)
#  zip_code                             :string
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  federal_submission_id                :string
#  primary_state_id_id                  :bigint
#  spouse_state_id_id                   :bigint
#  visitor_id                           :string
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
    }
  end

  def ask_for_signature_pin?
    true
  end

  def calculate_age(inclusive_of_jan_1: false, dob: primary.birth_date)
    # overwriting the base intake method b/c
    # MD always considers individuals to attain their age on their DOB
    raise StandardError, "Primary or spouse missing date-of-birth" if dob.nil?

    MultiTenantService.statefile.current_tax_year - dob.year
  end
end
