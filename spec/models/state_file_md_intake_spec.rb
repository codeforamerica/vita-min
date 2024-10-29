# == Schema Information
#
# Table name: state_file_md_intakes
#
#  id                                   :bigint           not null, primary key
#  account_holder_name                  :string
#  account_number                       :string
#  account_type                         :integer          default("unfilled"), not null
#  bank_name                            :string
#  city                                 :string
#  confirmed_permanent_address          :integer          default(0), not null
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
#  permanent_address_outside_md         :integer          default(0), not null
#  permanent_apartment                  :string
#  permanent_city                       :string
#  permanent_street                     :string
#  permanent_zip                        :string
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
require 'rails_helper'

RSpec.describe StateFileMdIntake, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  describe "#calculate_age" do
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 10), 1, 1) }

    it "doesn't include Jan 1st in the past tax year" do
      expect(intake.calculate_age(inclusive_of_jan_1: true, dob: dob)).to eq 10
      expect(intake.calculate_age(inclusive_of_jan_1: false, dob: dob)).to eq 10
    end
  end

  describe "#eligibility_filing_status" do
    subject(:intake) do
      create(:state_file_md_intake, eligibility_filing_status_mfj: :yes)
    end

    it "defines a correct enum" do
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(1)
      intake.update(eligibility_filing_status_mfj: :no)
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(2)
      intake.update(eligibility_filing_status_mfj: :unfilled)
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(0)
    end
  end
end
