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
#  primary_ssb_amount                         :decimal(12, 2)   default(0.0), not null
#  primary_ssn                                :string
#  primary_student_loan_interest_ded_amount   :decimal(12, 2)   default(0.0), not null
#  primary_suffix                             :string
#  proof_of_disability_submitted              :integer          default("unfilled"), not null
#  raw_direct_file_data                       :text
#  raw_direct_file_intake_data                :jsonb
#  referrer                                   :string
#  residence_county                           :string
#  routing_number                             :string
#  sign_in_count                              :integer          default(0), not null
#  sms_notification_opt_in                    :integer          default("unfilled"), not null
#  source                                     :string
#  spouse_birth_date                          :date
#  spouse_did_not_have_health_insurance       :integer          default("unfilled"), not null
#  spouse_disabled                            :integer          default("unfilled"), not null
#  spouse_esigned                             :integer          default("unfilled"), not null
#  spouse_esigned_at                          :datetime
#  spouse_first_name                          :string
#  spouse_last_name                           :string
#  spouse_middle_initial                      :string
#  spouse_signature_pin                       :text
#  spouse_ssb_amount                          :decimal(12, 2)   default(0.0), not null
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
require 'rails_helper'

RSpec.describe StateFileMdIntake, type: :model do
  describe "#calculate_age" do
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 10), 1, 1) }

    it "doesn't include Jan 1st in the past tax year" do
      expect(intake.calculate_age(dob, inclusive_of_jan_1: true)).to eq 10
      expect(intake.calculate_age(dob, inclusive_of_jan_1: false)).to eq 10
    end
  end

  describe "is_filer_55_and_older?" do

    context "when primary is 55 or older" do
      let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 55), 1, 1) }
      let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:primary)).to eq true
      end
    end

    context "when the primary is younger than 55" do
      let!(:intake) { create :state_file_md_intake, primary_birth_date: dob }
      let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 54), 1, 1) }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:primary)).to eq false
      end
    end

    context "when the spouse is 55 or older" do
      let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 55), 1, 1) }
      let(:intake) { create :state_file_md_intake, spouse_birth_date: dob }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:spouse)).to eq true
      end
    end

    context "when the spouse is younger than 55" do
      let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 54), 1, 1) }
      let(:intake) { create :state_file_md_intake, spouse_birth_date: dob }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:spouse)).to eq false
      end
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

  describe "before_save" do
    context "when payment_or_deposit_type changes to mail" do
      let!(:intake) do
        create :state_file_md_intake,
               payment_or_deposit_type: "direct_deposit",
               account_type: "checking",
               routing_number: "123456789",
               account_number: "123",
               withdraw_amount: 123,
               date_electronic_withdrawal: Date.parse("April 1, #{Rails.configuration.statefile_current_tax_year}"),
               account_holder_first_name: "Neil",
               account_holder_middle_initial: "B",
               account_holder_last_name: "Peart",
               account_holder_suffix: 'VIII',
               joint_account_holder_first_name: "Belle",
               joint_account_holder_middle_initial: "C",
               joint_account_holder_last_name: "Peart",
               joint_account_holder_suffix: "JR",
               has_joint_account_holder: "yes",
               bank_authorization_confirmed: "yes"
      end

      it "clears other account fields" do
        expect {
          intake.update(payment_or_deposit_type: "mail")
        }.to change(intake.reload, :account_type).to("unfilled")
          .and change(intake.reload, :routing_number).to(nil).and change(intake.reload, :account_number).to(nil)
          .and change(intake.reload, :withdraw_amount).to(nil)
          .and change(intake.reload, :date_electronic_withdrawal).to(nil)
          .and change(intake.reload, :account_holder_first_name).to(nil)
          .and change(intake.reload, :account_holder_middle_initial).to(nil)
          .and change(intake.reload, :account_holder_last_name).to(nil)
          .and change(intake.reload, :account_holder_suffix).to(nil)
          .and change(intake.reload, :joint_account_holder_first_name).to(nil)
          .and change(intake.reload, :joint_account_holder_middle_initial).to(nil)
          .and change(intake.reload, :joint_account_holder_last_name).to(nil)
          .and change(intake.reload, :joint_account_holder_suffix).to(nil)
          .and change(intake.reload, :has_joint_account_holder).to("unfilled")
          .and change(intake.reload, :bank_authorization_confirmed).to("unfilled")
      end
    end
  end

  describe "#has_dependent_without_health_insurance?" do
    let(:intake) { create(:state_file_md_intake) }

    context "when no dependents are present" do
      it "returns false" do
        expect(intake.has_dependent_without_health_insurance?).to eq(false)
      end
    end

    context "when dependents are present" do
      before do
        intake.dependents = dependents
      end

      context "when no dependents lack health insurance" do
        let(:dependents) do
          [
            create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
            create(:state_file_dependent, md_did_not_have_health_insurance: "no")
          ]
        end

        it "returns false" do
          expect(intake.has_dependent_without_health_insurance?).to eq(false)
        end
      end

      context "when at least one dependent lacks health insurance" do
        let(:dependents) do
          [
            create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
            create(:state_file_dependent, md_did_not_have_health_insurance: "yes")
          ]
        end

        it "returns true" do
          expect(intake.has_dependent_without_health_insurance?).to eq(true)
        end
      end
    end
  end

  describe "#address" do
    context "a confirmed address" do
        subject(:intake) { create :state_file_md_intake, :with_confirmed_address }

        it "returns the permanent address" do
          expect(intake.address).to eq("321 Main St Apt 2, Baltimore, MD 21202")
        end
      end

    context "an unconfirmed address" do
      subject(:intake) { create :state_file_md_intake, :with_permanent_address, confirmed_permanent_address: "no" }

      it "returns the submitted permanent address" do
        expect(intake.address).to eq("123 Main St Apt 1, Baltimore MD, 21201")
      end
    end
  end

  describe '#sum_1099_r_followup_type_for_filer' do

    context "with 1099Rs" do
      let!(:intake) { create(:state_file_md_intake, :with_spouse) }
      let!(:state_file_1099_r_without_followup) {
        create(
          :state_file1099_r,
          taxable_amount: 1_000,
          intake: intake)
      }
      let!(:state_file_md1099_r_followup_with_military_service_for_primary_1) do
        create(
          :state_file_md1099_r_followup,
          service_type: "military",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.primary.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_with_military_service_for_primary_2) do
        create(
          :state_file_md1099_r_followup,
          service_type: "military",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_500, intake: intake, recipient_ssn: intake.primary.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_with_military_service_for_spouse) do
        create(
          :state_file_md1099_r_followup,
          service_type: "military",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 2_000, intake: intake, recipient_ssn: intake.spouse.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_without_military) do
        create(
          :state_file_md1099_r_followup,
          service_type: "none",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake)
        )
      end

      it "totals the followup income" do
        expect(intake.sum_1099_r_followup_type_for_filer(:primary, :service_type_military?)).to eq(2_500)
        expect(intake.sum_1099_r_followup_type_for_filer(:spouse, :service_type_military?)).to eq(2_000)
      end
    end

    context "without 1099Rs" do
      let(:intake) { create(:state_file_md_intake) }
      it "returns 0" do
        expect(intake.sum_1099_r_followup_type_for_filer(:primary, :service_type_military?)).to eq(0)
        expect(intake.sum_1099_r_followup_type_for_filer(:spouse, :service_type_military?)).to eq(0)
      end
    end
  end
end
