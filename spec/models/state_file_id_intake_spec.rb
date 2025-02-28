# == Schema Information
#
# Table name: state_file_id_intakes
#
#  id                                             :bigint           not null, primary key
#  account_number                                 :string
#  account_type                                   :integer          default("unfilled"), not null
#  american_red_cross_fund_donation               :decimal(12, 2)
#  childrens_trust_fund_donation                  :decimal(12, 2)
#  consented_to_sms_terms                         :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions              :integer          default("unfilled"), not null
#  contact_preference                             :integer          default("unfilled"), not null
#  current_sign_in_at                             :datetime
#  current_sign_in_ip                             :inet
#  current_step                                   :string
#  date_electronic_withdrawal                     :date
#  df_data_import_succeeded_at                    :datetime
#  df_data_imported_at                            :datetime
#  donate_grocery_credit                          :integer          default("unfilled"), not null
#  eligibility_emergency_rental_assistance        :integer          default("unfilled"), not null
#  eligibility_withdrew_msa_fthb                  :integer          default("unfilled"), not null
#  email_address                                  :citext
#  email_address_verified_at                      :datetime
#  email_notification_opt_in                      :integer          default("unfilled"), not null
#  failed_attempts                                :integer          default(0), not null
#  federal_return_status                          :string
#  food_bank_fund_donation                        :decimal(12, 2)
#  guard_reserve_family_donation                  :decimal(12, 2)
#  has_health_insurance_premium                   :integer          default("unfilled"), not null
#  has_unpaid_sales_use_tax                       :integer          default("unfilled"), not null
#  hashed_ssn                                     :string
#  health_insurance_paid_amount                   :decimal(12, 2)
#  household_has_grocery_credit_ineligible_months :integer          default("unfilled"), not null
#  last_sign_in_at                                :datetime
#  last_sign_in_ip                                :inet
#  locale                                         :string           default("en")
#  locked_at                                      :datetime
#  message_tracker                                :jsonb
#  nongame_wildlife_fund_donation                 :decimal(12, 2)
#  opportunity_scholarship_program_donation       :decimal(12, 2)
#  payment_or_deposit_type                        :integer          default("unfilled"), not null
#  phone_number                                   :string
#  phone_number_verified_at                       :datetime
#  primary_birth_date                             :date
#  primary_disabled                               :integer          default("unfilled"), not null
#  primary_esigned                                :integer          default("unfilled"), not null
#  primary_esigned_at                             :datetime
#  primary_first_name                             :string
#  primary_has_grocery_credit_ineligible_months   :integer          default("unfilled"), not null
#  primary_last_name                              :string
#  primary_middle_initial                         :string
#  primary_months_ineligible_for_grocery_credit   :integer
#  primary_suffix                                 :string
#  raw_direct_file_data                           :text
#  raw_direct_file_intake_data                    :jsonb
#  received_id_public_assistance                  :integer          default("unfilled"), not null
#  referrer                                       :string
#  routing_number                                 :string
#  sign_in_count                                  :integer          default(0), not null
#  sms_notification_opt_in                        :integer          default("unfilled"), not null
#  source                                         :string
#  special_olympics_donation                      :decimal(12, 2)
#  spouse_birth_date                              :date
#  spouse_disabled                                :integer          default("unfilled"), not null
#  spouse_esigned                                 :integer          default("unfilled"), not null
#  spouse_esigned_at                              :datetime
#  spouse_first_name                              :string
#  spouse_has_grocery_credit_ineligible_months    :integer          default("unfilled"), not null
#  spouse_last_name                               :string
#  spouse_middle_initial                          :string
#  spouse_months_ineligible_for_grocery_credit    :integer
#  spouse_suffix                                  :string
#  total_purchase_amount                          :decimal(12, 2)
#  unfinished_intake_ids                          :text             default([]), is an Array
#  unsubscribed_from_email                        :boolean          default(FALSE), not null
#  veterans_support_fund_donation                 :decimal(12, 2)
#  withdraw_amount                                :integer
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  federal_submission_id                          :string
#  primary_state_id_id                            :bigint
#  spouse_state_id_id                             :bigint
#  visitor_id                                     :string
#
# Indexes
#
#  index_state_file_id_intakes_on_email_address        (email_address)
#  index_state_file_id_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_id_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_id_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
require 'rails_helper'

RSpec.describe StateFileIdIntake, type: :model do
  it_behaves_like :state_file_base_intake, factory: :state_file_id_intake

  describe "#eligible_1099rs" do
    let(:intake) {
      create(
        :state_file_id_intake, :with_spouse,
        primary_disabled: "no",
        spouse_disabled: "no",
        primary_birth_date: 60.years.ago,
        spouse_birth_date: 60.years.ago,
      )
    }
    let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, recipient_ssn: ssn, taxable_amount: taxable_amount) }

    context "1099r has taxable_amount" do
      let(:taxable_amount) { 100 }

      context "primary" do
        let(:ssn) { intake.primary.ssn }

        context "disabled" do
          before do
            intake.update(primary_disabled: "yes")
          end

          it "contains primary's 1099r" do
            expect(intake.eligible_1099rs).to include(state_file1099_r)
          end
        end

        context "senior" do
          before do
            intake.update(primary_birth_date: 66.years.ago)
          end

          it "contains primary's 1099r" do
            expect(intake.eligible_1099rs).to include(state_file1099_r)
          end
        end

        context "not disabled and not senior" do
          it "does not contain primary's 1099r" do
            expect(intake.eligible_1099rs).not_to include(state_file1099_r)
          end
        end
      end

      context "spouse" do
        let(:ssn) { intake.spouse.ssn }

        context "disabled" do
          before do
            intake.update(spouse_disabled: "yes")
          end

          it "contains spouse's 1099r" do
            expect(intake.eligible_1099rs).to include(state_file1099_r)
          end
        end

        context "senior" do
          before do
            intake.update(spouse_birth_date: 66.years.ago)
          end

          it "contains spouse's 1099r" do
            expect(intake.eligible_1099rs).to include(state_file1099_r)
          end
        end

        context "not disabled and not senior" do
          it "does not contain sposue's 1099r" do
            expect(intake.eligible_1099rs).not_to include(state_file1099_r)
          end
        end
      end
    end

    context "1099r has no taxable_amount" do
      let(:taxable_amount) { nil }

      context "even when primary senior and disabled" do
        let(:ssn) { intake.primary.ssn }
        before do
          intake.update(primary_disabled: "yes", primary_birth_date: 65.years.ago)
        end

        it "does not contain primary's 1099r" do
          expect(intake.eligible_1099rs).not_to include(state_file1099_r)
        end
      end

      context "even when spouse senior and disabled" do
        let(:ssn) { intake.spouse.ssn }
        before do
          intake.update(spouse_disabled: "yes", spouse_birth_date: 65.years.ago)
        end

        it "does not contain spouse's 1099r" do
          expect(intake.eligible_1099rs).not_to include(state_file1099_r)
        end
      end
    end
  end

  describe "#has_filer_between_62_and_65_years_old?" do
    let(:intake) { create(:state_file_id_intake) }

    context "with a 1099R but zero taxable amount" do
      let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

      it "is false" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq false
      end
    end

    context "when filer is under 62" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
      end

      it "is false" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq false
      end
    end

    context "when filer is within the age range qualifications" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 62, 1, 1)
      end

      it "is true" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq true
      end
    end

    context "when filer is above the age requirements" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
      end

      it "is false" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq false
      end
    end
  end

  context "when married filing jointly" do
    let(:intake) { create :state_file_id_intake, :mfj_filer_with_json}
    let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 25) }

    context "when both spouses are under 62" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
        intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
      end

      it "is false" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq false
      end
    end

    context "when primary is 62 and spouse is under 62" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 61, 1, 1)
        intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
      end

      it "is true" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq true
      end
    end

    context "when primary is under 62 and spouse is 62" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
        intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 61, 1, 1)
      end

      it "is true" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq true
      end
    end

    context "when both spouses are 65" do
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
      end

      it "is false" do
        expect(intake.has_filer_between_62_and_65_years_old?).to eq false
      end
    end
  end
end
