# == Schema Information
#
# Table name: state_file_nj_intakes
#
#  id                                                     :bigint           not null, primary key
#  account_number                                         :string
#  account_type                                           :integer          default("unfilled"), not null
#  claimed_as_dep                                         :integer
#  claimed_as_eitc_qualifying_child                       :integer          default("unfilled"), not null
#  confirmed_w2_ids                                       :integer          default([]), is an Array
#  consented_to_sms_terms                                 :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions                      :integer          default("unfilled"), not null
#  contact_preference                                     :integer          default("unfilled"), not null
#  county                                                 :string
#  current_sign_in_at                                     :datetime
#  current_sign_in_ip                                     :inet
#  current_step                                           :string
#  date_electronic_withdrawal                             :date
#  df_data_import_succeeded_at                            :datetime
#  df_data_imported_at                                    :datetime
#  eligibility_all_members_health_insurance               :integer          default("unfilled"), not null
#  eligibility_lived_in_state                             :integer          default("unfilled"), not null
#  eligibility_out_of_state_income                        :integer          default("unfilled"), not null
#  eligibility_retirement_warning_continue                :integer          default("unfilled")
#  email_address                                          :citext
#  email_address_verified_at                              :datetime
#  email_notification_opt_in                              :integer          default("unfilled"), not null
#  estimated_tax_payments                                 :decimal(12, 2)
#  extension_payments                                     :integer          default(0), not null
#  failed_attempts                                        :integer          default(0), not null
#  fed_taxable_income                                     :integer
#  fed_wages                                              :integer
#  federal_return_status                                  :string
#  has_estimated_payments                                 :integer          default("unfilled"), not null
#  hashed_ssn                                             :string
#  homeowner_home_subject_to_property_taxes               :integer          default("unfilled"), not null
#  homeowner_main_home_multi_unit                         :integer          default("unfilled"), not null
#  homeowner_main_home_multi_unit_max_four_one_commercial :integer          default("unfilled"), not null
#  homeowner_more_than_one_main_home_in_nj                :integer          default("unfilled"), not null
#  homeowner_same_home_spouse                             :integer          default("unfilled"), not null
#  homeowner_shared_ownership_not_spouse                  :integer          default("unfilled"), not null
#  household_rent_own                                     :integer          default("unfilled"), not null
#  last_sign_in_at                                        :datetime
#  last_sign_in_ip                                        :inet
#  locale                                                 :string           default("en")
#  locked_at                                              :datetime
#  medical_expenses                                       :decimal(12, 2)   default(0.0), not null
#  message_tracker                                        :jsonb
#  municipality_code                                      :string
#  municipality_name                                      :string
#  overpayments                                           :decimal(12, 2)
#  payment_or_deposit_type                                :integer          default("unfilled"), not null
#  permanent_apartment                                    :string
#  permanent_city                                         :string
#  permanent_street                                       :string
#  permanent_zip                                          :string
#  phone_number                                           :string
#  phone_number_verified_at                               :datetime
#  primary_birth_date                                     :date
#  primary_contribution_gubernatorial_elections           :integer          default("unfilled"), not null
#  primary_disabled                                       :integer          default("unfilled"), not null
#  primary_esigned                                        :integer          default("unfilled"), not null
#  primary_esigned_at                                     :datetime
#  primary_first_name                                     :string
#  primary_last_name                                      :string
#  primary_middle_initial                                 :string
#  primary_signature                                      :string
#  primary_ssn                                            :string
#  primary_suffix                                         :string
#  primary_veteran                                        :integer          default("unfilled"), not null
#  property_tax_paid                                      :decimal(12, 2)
#  raw_direct_file_data                                   :text
#  raw_direct_file_intake_data                            :jsonb
#  referrer                                               :string
#  rent_paid                                              :decimal(12, 2)
#  routing_number                                         :string
#  sales_use_tax                                          :decimal(12, 2)
#  sales_use_tax_calculation_method                       :integer          default("unfilled"), not null
#  sign_in_count                                          :integer          default(0), not null
#  sms_notification_opt_in                                :integer          default("unfilled"), not null
#  source                                                 :string
#  spouse_birth_date                                      :date
#  spouse_claimed_as_eitc_qualifying_child                :integer          default("unfilled"), not null
#  spouse_contribution_gubernatorial_elections            :integer          default("unfilled"), not null
#  spouse_death_year                                      :integer
#  spouse_disabled                                        :integer          default("unfilled"), not null
#  spouse_esigned                                         :integer          default("unfilled"), not null
#  spouse_esigned_at                                      :datetime
#  spouse_first_name                                      :string
#  spouse_last_name                                       :string
#  spouse_middle_initial                                  :string
#  spouse_ssn                                             :string
#  spouse_suffix                                          :string
#  spouse_veteran                                         :integer          default("unfilled"), not null
#  tenant_access_kitchen_bath                             :integer          default("unfilled"), not null
#  tenant_building_multi_unit                             :integer          default("unfilled"), not null
#  tenant_home_subject_to_property_taxes                  :integer          default("unfilled"), not null
#  tenant_more_than_one_main_home_in_nj                   :integer          default("unfilled"), not null
#  tenant_same_home_spouse                                :integer          default("unfilled"), not null
#  tenant_shared_rent_not_spouse                          :integer          default("unfilled"), not null
#  unfinished_intake_ids                                  :text             default([]), is an Array
#  unsubscribed_from_email                                :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases                         :integer          default("unfilled"), not null
#  withdraw_amount                                        :integer
#  created_at                                             :datetime         not null
#  updated_at                                             :datetime         not null
#  federal_submission_id                                  :string
#  primary_state_id_id                                    :bigint
#  spouse_state_id_id                                     :bigint
#  visitor_id                                             :string
#
# Indexes
#
#  index_state_file_nj_intakes_on_email_address        (email_address)
#  index_state_file_nj_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nj_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nj_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
require 'rails_helper'

RSpec.describe StateFileNjIntake, type: :model do
  describe "#disqualifying_df_data_reason" do
    context "when federal non taxable interest income exceeds 10k" do
      let(:intake) { create :state_file_nj_intake, :df_data_minimal }
      before do
        intake.direct_file_data.fed_tax_exempt_interest = 10_001
      end

      it "returns exempt_interest_exceeds_10k" do
        expect(intake.disqualifying_df_data_reason).to eq :exempt_interest_exceeds_10k
      end
    end

    context "when gov bonds are 10k and federal tax exempt interest amt is 1" do
      let(:intake) { create :state_file_nj_intake, :df_data_exempt_interest }
      it "returns exempt_interest_exceeds_10k" do
        expect(intake.disqualifying_df_data_reason).to eq :exempt_interest_exceeds_10k
      end
    end

    context "when there are no disqualifying reasons" do
      let(:intake) { create :state_file_nj_intake, :df_data_two_deps }
      it "returns nil" do
        expect(intake.disqualifying_df_data_reason).to eq nil
      end
    end
  end

  describe "#health_insurance_eligibility" do
    context "when answered yes to eligibility_all_members_health_insurance" do
      let(:intake) { create :state_file_nj_intake, eligibility_all_members_health_insurance: "yes" }
      it "returns eligible" do
        expect(intake.health_insurance_eligibility).to eq "eligible"
      end
    end

    context "when answered no to eligibility_all_members_health_insurance" do

      context "when eligibility_made_less_than_threshold?=true and eligibility_claimed_as_dependent?=true" do
        let(:intake) { create :state_file_nj_intake, eligibility_all_members_health_insurance: "no" }
        it "returns eligible" do
          allow(intake).to receive(:eligibility_made_less_than_threshold?).and_return true
          allow(intake).to receive(:eligibility_claimed_as_dependent?).and_return true
          expect(intake.health_insurance_eligibility).to eq "eligible"
        end
      end

      context "when eligibility_made_less_than_threshold?=false and eligibility_claimed_as_dependent?=true" do
        let(:intake) { create :state_file_nj_intake, eligibility_all_members_health_insurance: "no" }
        it "returns eligible" do
          allow(intake).to receive(:eligibility_made_less_than_threshold?).and_return false
          allow(intake).to receive(:eligibility_claimed_as_dependent?).and_return true
          expect(intake.health_insurance_eligibility).to eq "eligible"
        end
      end

      context "when eligibility_made_less_than_threshold?=true and eligibility_claimed_as_dependent?=false" do
        let(:intake) { create :state_file_nj_intake, eligibility_all_members_health_insurance: "no" }
        it "returns eligible" do
          allow(intake).to receive(:eligibility_made_less_than_threshold?).and_return true
          allow(intake).to receive(:eligibility_claimed_as_dependent?).and_return false
          expect(intake.health_insurance_eligibility).to eq "eligible"
        end
      end

      context "when eligibility_made_less_than_threshold?=false and eligibility_claimed_as_dependent?=false" do
        let(:intake) { create :state_file_nj_intake, eligibility_all_members_health_insurance: "no" }
        it "returns ineligible" do
          allow(intake).to receive(:eligibility_made_less_than_threshold?).and_return false
          allow(intake).to receive(:eligibility_claimed_as_dependent?).and_return false
          expect(intake.health_insurance_eligibility).to eq "ineligible"
        end
      end
    end
  end

  describe "#eligibility_made_less_than_threshold?" do

    shared_examples :eligibility_with_threshold do |threshold|
      it "returns true if NJ gross income below #{threshold}" do
        allow(intake.calculator.lines).to receive(:[]).with(:NJ1040_LINE_29).and_return(double(value: threshold - 1))
        expect(intake.eligibility_made_less_than_threshold?).to eq true
      end

      it "returns true if NJ gross income equals #{threshold}" do
        allow(intake.calculator.lines).to receive(:[]).with(:NJ1040_LINE_29).and_return(double(value: threshold))
        expect(intake.eligibility_made_less_than_threshold?).to eq true
      end

      it "returns false if NJ gross income over #{threshold}" do
        allow(intake.calculator.lines).to receive(:[]).with(:NJ1040_LINE_29).and_return(double(value: threshold + 1))
        expect(intake.eligibility_made_less_than_threshold?).to eq false
      end
    end

    context "when filing status single" do
      let(:intake) { create :state_file_nj_intake }
      it_behaves_like :eligibility_with_threshold, 10_000
    end

    context "when filing status MFS" do
      let(:intake) { create :state_file_nj_intake, :married_filing_separately }
      it_behaves_like :eligibility_with_threshold, 10_000
    end

    context "when filing status MFJ" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly }
      it_behaves_like :eligibility_with_threshold, 20_000
    end

    context "when filing status HOH" do
      let(:intake) { create :state_file_nj_intake, :head_of_household }
      it_behaves_like :eligibility_with_threshold, 20_000
    end

    context "when filing status QW" do
      let(:intake) { create :state_file_nj_intake, :qualifying_widow }
      it_behaves_like :eligibility_with_threshold, 20_000
    end
  end

  describe "#eligibility_claimed_as_dependent?" do
    context "when mfj" do
      context "when only spouse claimed as dependent" do
        let(:intake) { create(:state_file_nj_intake, :df_data_mfj_spouse_claimed_dep) }
        it "returns false" do
          expect(intake.eligibility_claimed_as_dependent?).to eq false
        end
      end

      context "when only primary claimed as dependent" do
        let(:intake) { create(:state_file_nj_intake, :df_data_mfj_primary_claimed_dep) }
        it "returns false" do
          expect(intake.eligibility_claimed_as_dependent?).to eq false
        end
      end

      context "when neither claimed as dependent" do
        let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
        it "returns false" do
          expect(intake.eligibility_claimed_as_dependent?).to eq false
        end
      end

      context "when both claimed as dependent" do
        let(:intake) { create(:state_file_nj_intake, :df_data_mfj_both_claimed_dep) }
        it "returns true" do
          expect(intake.eligibility_claimed_as_dependent?).to eq true
        end
      end
    end

    context "when not mfj" do
      context "when claimed as dependent" do
        let(:intake) { create(:state_file_nj_intake, :df_data_claimed_as_dependent) }
        it "returns true" do
          expect(intake.eligibility_claimed_as_dependent?).to eq true
        end
      end

      context "when not claimed as dependent" do
        let(:intake) { create(:state_file_nj_intake) }
        it "returns false" do
          expect(intake.eligibility_claimed_as_dependent?).to eq false
        end
      end
    end
  end

  describe "#validate_state_specific_w2_requirements" do
    let(:intake) { create :state_file_nj_intake }
    let(:w2) {
      create(:state_file_w2,
             employer_state_id_num: "001245788",
             employer_ein: '123445678',
             local_income_tax_amount: 200,
             local_wages_and_tips_amount: 8000,
             locality_nm: "NJ",
             state_file_intake: intake,
             state_income_tax_amount: 600,
             state_wages_amount: 8000,
             box14_fli: 0,
             box14_ui_wf_swf: 0,
             w2_index: 0,
             wages: 1000
            )
    }
    context "taxpayer has not reviewed the w2" do

      it "does not permit state_wages_amount to be 0 if federal wages is non-zero" do
        intake.confirmed_w2_ids = []
        w2.state_wages_amount = 0
        intake.validate_state_specific_w2_requirements(w2)
        expect(w2.errors[:state_wages_amount]).to be_present
        expect(w2.valid?(:state_file_edit)).to eq false
        expect(w2.valid?(:state_file_income_review)).to eq false
      end
    end

    context "taxpayer has reviewed the w2" do
      before do
        intake.confirmed_w2_ids = [w2.id]
      end
      it "permits state_wages_amount to be 0 if federal wages is non-zero" do
        w2.state_wages_amount = 0
        w2.state_income_tax_amount = 0
        intake.validate_state_specific_w2_requirements(w2)
        expect(w2.errors[:state_wages_amount]).not_to be_present
        expect(w2.valid?(:state_file_edit)).to eq true
        expect(w2.valid?(:state_file_income_review)).to eq true
      end
    end
  end

  describe "#medical_expenses_threshold" do
    let(:intake) { create :state_file_nj_intake }
    it "returns 2% of NJ Gross Income" do
      allow(intake.calculator.lines).to receive(:[]).with(:NJ1040_LINE_29).and_return(double(value: 10_000))
      expect(intake.medical_expenses_threshold).to eq 200
    end

    it "rounds down to whole number" do
      allow(intake.calculator.lines).to receive(:[]).with(:NJ1040_LINE_29).and_return(double(value: 12_345))
      expect(intake.medical_expenses_threshold).to eq 246
    end
  end
end
