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
#  extension_payments_amount                  :decimal(12, 2)
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
#  paid_extension_payments                    :integer          default("unfilled"), not null
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
#  primary_proof_of_disability_submitted      :integer          default("unfilled"), not null
#  primary_signature                          :string
#  primary_signature_pin                      :text
#  primary_ssb_amount                         :decimal(12, 2)
#  primary_ssn                                :string
#  primary_student_loan_interest_ded_amount   :decimal(12, 2)   default(0.0), not null
#  primary_suffix                             :string
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
#  spouse_proof_of_disability_submitted       :integer          default("unfilled"), not null
#  spouse_signature_pin                       :text
#  spouse_ssb_amount                          :decimal(12, 2)
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
#  index_state_file_md_intakes_email_verified          (id) WHERE ((email_address IS NOT NULL) AND (email_address_verified_at IS NOT NULL))
#  index_state_file_md_intakes_on_created_at           (created_at)
#  index_state_file_md_intakes_on_email_address        (email_address)
#  index_state_file_md_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_md_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_md_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#  index_state_file_md_intakes_phone_verified          (id) WHERE ((phone_number IS NOT NULL) AND (phone_number_verified_at IS NOT NULL))
#
require 'rails_helper'

RSpec.describe StateFileMdIntake, type: :model do
  include StateFileIntakeHelper

  describe "#calculate_age" do
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.current_tax_year - 10), 1, 1) }

    it "doesn't include Jan 1st in the past tax year" do
      expect(intake.calculate_age(dob, inclusive_of_jan_1: true)).to eq 10
      expect(intake.calculate_age(dob, inclusive_of_jan_1: false)).to eq 10
    end
  end

  describe "is_filer_55_and_older?" do

    context "when primary is 55 or older" do
      let(:dob) { Date.new((MultiTenantService.statefile.current_tax_year - 55), 1, 1) }
      let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:primary)).to eq true
      end
    end

    context "when the primary is younger than 55" do
      let!(:intake) { create :state_file_md_intake, primary_birth_date: dob }
      let(:dob) { Date.new((MultiTenantService.statefile.current_tax_year - 54), 1, 1) }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:primary)).to eq false
      end
    end

    context "when the spouse is 55 or older" do
      let(:dob) { Date.new((MultiTenantService.statefile.current_tax_year - 55), 1, 1) }
      let(:intake) { create :state_file_md_intake, spouse_birth_date: dob }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:spouse)).to eq true
      end
    end

    context "when the spouse is younger than 55" do
      let(:dob) { Date.new((MultiTenantService.statefile.current_tax_year - 54), 1, 1) }
      let(:intake) { create :state_file_md_intake, spouse_birth_date: dob }
      it "returns true" do
        expect(intake.is_filer_55_and_older?(:spouse)).to eq false
      end
    end
  end


  describe "#disqualifying_df_data_reason" do
    context "spouse is NRA (non-resident alien)" do
      let(:intake) { create :state_file_md_intake, :with_spouse_ssn_nil, filing_status: "married_filing_separately"}

      it "returns spouse_nra_html" do
        expect(intake.disqualifying_df_data_reason).to eq :spouse_nra_html
      end
    end

    context "has out of state w2" do
      let(:intake) { create :state_file_md_intake, :df_data_2_w2s, :with_w2s_synced }

      it "returns has_out_of_state_w2" do
        w2 = intake.direct_file_data.w2_nodes.first
        state_abbreviation_cd = w2.at("W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd")
        state_abbreviation_cd.inner_html = "UT"

        expect(intake.disqualifying_df_data_reason).to eq :has_out_of_state_w2
      end
    end

    context "is mfj and has dependent filer" do
      let(:intake) { create :state_file_md_intake, :with_spouse }

      it "returns mfj_and_dependent_html" do
        allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(true)
        expect(intake.disqualifying_df_data_reason).to eq :mfj_and_dependent_html
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

  describe "#sum_two_1099_r_followup_types_for_filer" do
    context "with followups present" do
      let!(:intake) { create(:state_file_md_intake, :with_spouse) }
      let(:state_file_md1099_r_followup_with_one_followup_criterion_for_primary) do
        create(
          :state_file_md1099_r_followup,
          income_source: "pension_annuity_endowment",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.primary.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_with_both_followup_criteria_for_spouse_1) do
        create(
          :state_file_md1099_r_followup,
          income_source: "pension_annuity_endowment",
          service_type: "public_safety",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.spouse.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_with_both_followup_criteria_for_spouse_2) do
        create(
          :state_file_md1099_r_followup,
          income_source: "pension_annuity_endowment",
          service_type: "public_safety",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_500, intake: intake, recipient_ssn: intake.spouse.ssn)
        )
      end

      context "when only one followup is present" do
        it "returns 0" do
          expect(intake.sum_two_1099_r_followup_types_for_filer(:primary, :income_source_pension_annuity_endowment?, :service_type_public_safety? )).to eq(0)
        end
      end

      context "when the income source qualifies the filer" do
        it "returns the sum of the taxable amount" do
          expect(intake.sum_two_1099_r_followup_types_for_filer(:spouse, :income_source_pension_annuity_endowment?, :service_type_public_safety? )).to eq(2500)
        end
      end
    end

    context "when none of the 1099-Rs are from a qualifying source" do
      let!(:intake) { create(:state_file_md_intake, :with_spouse) }
      let(:state_file_md1099_r_followup_with_one_followup_criterion_for_primary) do
        create(
          :state_file_md1099_r_followup,
          income_source: "other",
          service_type: "none",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.primary.ssn)
        )
      end
      it "returns 0" do
        expect(intake.sum_two_1099_r_followup_types_for_filer(:primary, :income_source_pension_annuity_endowment?, :service_type_public_safety? )).to eq(0)
      end
    end

    context "without 1099Rs" do
      let(:intake) { create(:state_file_md_intake) }
      it "returns 0" do
        expect(intake.sum_two_1099_r_followup_types_for_filer(:primary, :income_source_pension_annuity_endowment?, :service_type_public_safety? )).to eq(0)
        expect(intake.sum_two_1099_r_followup_types_for_filer(:spouse, :income_source_pension_annuity_endowment?, :service_type_public_safety? )).to eq(0)
      end
    end
  end

  describe "#at_least_one_disabled_filer_with_proof?" do
    context "when mfj" do
      let(:intake) do
        create(:state_file_md_intake,
               :with_spouse,
                primary_disabled: "yes",
                spouse_disabled: "yes",
                primary_proof_of_disability_submitted: primary_proof_of_disability_submitted,
                spouse_proof_of_disability_submitted: spouse_proof_of_disability_submitted,
        )
      end

      context "one filer has proof of disability" do
        context "primary" do
          let(:primary_proof_of_disability_submitted) { "yes" }
          let(:spouse_proof_of_disability_submitted) { "no" }

          it "returns true" do
            expect(intake.at_least_one_disabled_filer_with_proof?).to eq(true)
          end
        end

        context "spouse" do
          let(:primary_proof_of_disability_submitted) { "no" }
          let(:spouse_proof_of_disability_submitted) { "yes" }

          it "returns true" do
            expect(intake.at_least_one_disabled_filer_with_proof?).to eq(true)
          end
        end
      end

      context "both filers have proof of disability" do
        let(:primary_proof_of_disability_submitted) { "yes" }
        let(:spouse_proof_of_disability_submitted) { "yes" }

        it "returns true" do
          expect(intake.at_least_one_disabled_filer_with_proof?).to eq(true)
        end
      end

      context "neither filer has proof of disability" do
        let(:primary_proof_of_disability_submitted) { "no" }
        let(:spouse_proof_of_disability_submitted) { "no" }

        it "returns false" do
          expect(intake.at_least_one_disabled_filer_with_proof?).to eq(false)
        end
      end
    end

    context "when not mfj" do
      let(:intake) do
        create(:state_file_md_intake,
               filing_status: "single",
               primary_disabled: "yes",
               primary_proof_of_disability_submitted: proof_of_disability_submitted
        )
      end

      context "when there is proof" do
        let(:proof_of_disability_submitted) { "yes" }

        it "returns true" do
          expect(intake.at_least_one_disabled_filer_with_proof?).to eq(true)
        end
      end

      context "when there is no proof" do
        let(:proof_of_disability_submitted) { "no" }

        it "returns false" do
          expect(intake.at_least_one_disabled_filer_with_proof?).to eq(false)
        end
      end
    end
  end

  describe "qualifies_for_pension_exclusion?" do
    before do
      allow_any_instance_of(StateFileMdIntake).to receive(:at_least_one_disabled_filer_with_proof?).and_return is_disabled
    end
    let(:senior_primary_dob) { Date.new((MultiTenantService.statefile.current_tax_year - 65), 1, 1) }
    let(:non_senior_spouse_dob) { Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1) }
    let(:intake) { create :state_file_md_intake, :with_spouse, primary_birth_date: senior_primary_dob, spouse_birth_date: non_senior_spouse_dob }


    context "when the filer is a senior and is disabled with proof" do
      let(:is_disabled) { true }
      it "returns true" do
        expect(intake.qualifies_for_pension_exclusion?(:primary)).to eq(true)
      end
    end

    context "when the filer is a senior and is not disabled with proof" do
      let(:is_disabled) { false }
      it "returns true" do
        expect(intake.qualifies_for_pension_exclusion?(:primary)).to eq(true)
      end
    end

    context "when the filer is not a senior but is disabled with proof" do
      let(:is_disabled) { true }
      it "returns true" do
        expect(intake.qualifies_for_pension_exclusion?(:spouse)).to eq(true)
      end
    end

    context "when the filer is not a senior nor are they disabled with proof" do
      let(:is_disabled) { false }
      it "returns true" do
        expect(intake.qualifies_for_pension_exclusion?(:spouse)).to eq(false)
      end
    end
  end

  describe "has_filer_under_65?" do
    let(:filing_status) { "single" }
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob, spouse_birth_date: spouse_dob, filing_status: filing_status }

    context "not mfj" do
      let(:spouse_dob) { nil }

      context "under 65" do
        let(:dob) { age_at_end_of_tax_year(55) }

        it "returns true" do
          expect(intake.has_filer_under_65?).to eq(true)
        end
      end

      context "over 65" do
        let(:dob) { age_at_end_of_tax_year(66) }

        it "returns true" do
          expect(intake.has_filer_under_65?).to eq(false)
        end
      end
    end

    context "mfj" do
      let(:filing_status) { "married_filing_jointly" }
      let(:spouse_dob) { age_at_end_of_tax_year(70) }

      context "primary" do
        context "under 65" do
          let(:dob) { age_at_end_of_tax_year(64) }

          it "returns true" do
            expect(intake.has_filer_under_65?).to eq(true)
          end
        end

        context "over 65" do
          let(:dob) { age_at_end_of_tax_year(66) }

          it "returns true" do
            expect(intake.has_filer_under_65?).to eq(false)
          end
        end
      end

      context "spouse" do
        let(:dob) { age_at_end_of_tax_year(70) }

        context "under 65" do
          let(:spouse_dob) { age_at_end_of_tax_year(55) }

          it "returns true" do
            expect(intake.has_filer_under_65?).to eq(true)
          end
        end

        context "over 65" do
          let(:spouse_dob) { age_at_end_of_tax_year(66) }

          it "returns true" do
            expect(intake.has_filer_under_65?).to eq(false)
          end
        end
      end
    end
  end

  describe "no_proof_of_disability_submitted?" do
    let(:intake) { create :state_file_md_intake, filing_status: filing_status }

    before do
      intake.update(primary_proof_of_disability_submitted: primary_proof)
      intake.update(spouse_proof_of_disability_submitted: spouse_proof)
    end

    context "not mfj" do
      let(:filing_status) { "single" }
      let(:spouse_proof) { "unfilled" }

      context "with primary_proof_of_disability_submitted_no?" do
        let(:primary_proof) { "no"}

        it "should return true" do
          expect(intake.no_proof_of_disability_submitted?).to eq(true)
        end
      end

      context "with primary_proof_of_disability_submitted_yes?" do
        let(:primary_proof) { "yes"}

        it "should return false" do
          expect(intake.no_proof_of_disability_submitted?).to eq(false)
        end
      end
    end

    context "mfj" do
      let(:filing_status) { "married_filing_jointly" }
      let(:primary_proof) { "yes" }
      let(:spouse_proof) { "yes" }

      context "both with proof" do
        it "should return false" do
          expect(intake.no_proof_of_disability_submitted?).to eq(false)
        end
      end

      context "with primary_proof_of_disability_submitted_no?" do
        let(:primary_proof) { "no"}

        it "should return true" do
          expect(intake.no_proof_of_disability_submitted?).to eq(false)
        end
      end

      context "With spouse_proof_of_disability_submitted_no?" do
        let(:spouse_proof) { "no"}

        it "should return true" do
          expect(intake.no_proof_of_disability_submitted?).to eq(false)
        end
      end

      context "without any submitted proof" do
        let(:primary_proof) { "no"}
        let(:spouse_proof) { "no"}

        it "should return true" do
          expect(intake.no_proof_of_disability_submitted?).to eq(true)
        end
      end
    end
  end

  describe "has_at_least_one_disabled_filer?" do
    let(:intake) { create :state_file_md_intake }

    before do
      intake.update(primary_disabled: primary_disabled)
      intake.update(spouse_disabled: spouse_disabled)
    end

    context "with disabled primary" do
      let(:primary_disabled) { "yes" }
      let(:spouse_disabled) { "unfilled" }

      it "should return true" do
        expect(intake.has_at_least_one_disabled_filer?).to eq(true)
      end
    end

    context "with disabled spouse" do
      let(:primary_disabled) { "unfilled" }
      let(:spouse_disabled) { "yes" }

      it "should return true" do
        expect(intake.has_at_least_one_disabled_filer?).to eq(true)
      end
    end

    context "with no one disabled" do
      let(:primary_disabled) { "no" }
      let(:spouse_disabled) { "no" }

      it "should return false" do
        expect(intake.has_at_least_one_disabled_filer?).to eq(false)
      end
    end

    context "with disabled spouse not disabled primary" do
      let(:primary_disabled) { "no" }
      let(:spouse_disabled) { "yes" }

      it "should return true" do
        expect(intake.has_at_least_one_disabled_filer?).to eq(true)
      end
    end
  end

  describe "should_warn_about_pension_exclusion?" do
    let(:intake) { create :state_file_md_intake }
    context "with a filler under 65" do
      before do
        allow_any_instance_of(StateFileMdIntake).to receive(:has_filer_under_65?).and_return true
      end

      context "with eligible 1099r"  do
        let!(:first_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 200) }
        let!(:second_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

        it "should return true" do
          expect(intake.should_warn_about_pension_exclusion?).to eq(true)
        end
      end

      context "with only ineligible 1099rs"  do
        let!(:first_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }
        let!(:second_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

        it "should return false" do
          expect(intake.should_warn_about_pension_exclusion?).to eq(false)
        end
      end

      context "with no 1099rs"  do
        it "should return false" do
          expect(intake.should_warn_about_pension_exclusion?).to eq(false)
        end
      end
    end

    context "with no filers under 65" do
      before do
        allow_any_instance_of(StateFileMdIntake).to receive(:has_filer_under_65?).and_return false
      end

      context "with eligible 1099r"  do
        let!(:first_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 200) }
        let!(:second_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

        it "should return false" do
          expect(intake.should_warn_about_pension_exclusion?).to eq(false)
        end
      end

      context "with only ineligible 1099rs"  do
        let!(:first_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }
        let!(:second_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

        it "should return false" do
          expect(intake.should_warn_about_pension_exclusion?).to eq(false)
        end
      end

      context "with no 1099rs"  do
        it "should return false" do
          expect(intake.should_warn_about_pension_exclusion?).to eq(false)
        end
      end
    end

    describe "#nra_spouse?" do
      context "when filing status is not mfs" do
        let(:intake) { create :state_file_md_intake, filing_status: "single" }
        it "should return false" do
          expect(intake.nra_spouse?).to eq(false)
        end
      end

      context "when filing status is mfs" do
        let(:intake) { create :state_file_md_intake, :with_spouse }
        context "with a spouse ssn" do
          it "should return false" do
            expect(intake.nra_spouse?).to eq(false)
          end
        end

        context "with spouse ssn nil" do
          let(:intake) { create :state_file_md_intake, :with_spouse_ssn_nil, filing_status: "married_filing_separately"}

          it "should return true" do
            expect(intake.nra_spouse?).to eq(true)
          end
        end
      end
    end
  end

  describe "#mfj_and_dependent?" do
    context "is not mfj" do
      let(:intake) { create :state_file_md_intake, filing_status: "single" }

      it "returns false" do
        expect(intake.mfj_and_dependent?).to eq false
      end

      context "is dependent" do
        it "returns false" do
          allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(true)
          expect(intake.mfj_and_dependent?).to eq false
        end
      end
    end

    context "is mfj" do
      let(:intake) { create :state_file_md_intake, :with_spouse }

      context "has no dependents" do
        it "returns false" do
          expect(intake.mfj_and_dependent?).to eq false
        end
      end

      context "has primary dependent" do
        it "returns true" do
          allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(true)
          expect(intake.mfj_and_dependent?).to eq true
        end
      end

      context "has spouse dependent" do
        it "returns true" do
          allow(intake.direct_file_data).to receive(:spouse_is_a_dependent?).and_return(true)
          expect(intake.mfj_and_dependent?).to eq true
        end
      end
    end
  end

  describe "#direct_file_address_is_po_box?" do
    let(:intake) { create :state_file_md_intake }

    context "if there is not direct file data" do
      before do
        intake.raw_direct_file_data = nil
      end
      it "returns false" do
        expect(intake.direct_file_address_is_po_box?).to eq(false)
      end
    end

    context "if the mailing street is a po box" do
      before do
        intake.direct_file_data.mailing_street = "PO Box 123"
      end
      it "returns true" do
        expect(intake.direct_file_address_is_po_box?).to eq(true)
      end
    end

    context "if the mailing apartment is a po box" do
      before do
        intake.direct_file_data.mailing_apartment = "PO Box 555"
      end
      it "returns true" do
        expect(intake.direct_file_address_is_po_box?).to eq(true)
      end
    end
  end
end
