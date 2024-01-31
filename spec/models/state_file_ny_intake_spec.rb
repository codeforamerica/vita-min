# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                                 :bigint           not null, primary key
#  account_number                     :string
#  account_type                       :integer          default("unfilled"), not null
#  bank_name                          :string
#  confirmed_permanent_address        :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions  :integer          default("unfilled"), not null
#  contact_preference                 :integer          default("unfilled"), not null
#  current_sign_in_at                 :datetime
#  current_sign_in_ip                 :inet
#  current_step                       :string
#  date_electronic_withdrawal         :date
#  df_data_import_failed_at           :datetime
#  eligibility_lived_in_state         :integer          default("unfilled"), not null
#  eligibility_out_of_state_income    :integer          default("unfilled"), not null
#  eligibility_part_year_nyc_resident :integer          default("unfilled"), not null
#  eligibility_withdrew_529           :integer          default("unfilled"), not null
#  eligibility_yonkers                :integer          default("unfilled"), not null
#  email_address                      :citext
#  email_address_verified_at          :datetime
#  failed_attempts                    :integer          default(0), not null
#  federal_return_status              :string
#  hashed_ssn                         :string
#  household_cash_assistance          :integer
#  household_fed_agi                  :integer
#  household_ny_additions             :integer
#  household_other_income             :integer
#  household_own_assessments          :integer
#  household_own_propety_tax          :integer
#  household_rent_adjustments         :integer
#  household_rent_amount              :integer
#  household_rent_own                 :integer          default("unfilled"), not null
#  household_ssi                      :integer
#  last_sign_in_at                    :datetime
#  last_sign_in_ip                    :inet
#  locked_at                          :datetime
#  mailing_country                    :string
#  mailing_state                      :string
#  nursing_home                       :integer          default("unfilled"), not null
#  ny_mailing_apartment               :string
#  ny_mailing_city                    :string
#  ny_mailing_street                  :string
#  ny_mailing_zip                     :string
#  nyc_maintained_home                :integer          default("unfilled"), not null
#  nyc_residency                      :integer          default("unfilled"), not null
#  occupied_residence                 :integer          default("unfilled"), not null
#  payment_or_deposit_type            :integer          default("unfilled"), not null
#  permanent_address_outside_ny       :integer          default("unfilled"), not null
#  permanent_apartment                :string
#  permanent_city                     :string
#  permanent_street                   :string
#  permanent_zip                      :string
#  phone_number                       :string
#  phone_number_verified_at           :datetime
#  primary_birth_date                 :date
#  primary_email                      :string
#  primary_esigned                    :integer          default("unfilled"), not null
#  primary_esigned_at                 :datetime
#  primary_first_name                 :string
#  primary_last_name                  :string
#  primary_middle_initial             :string
#  primary_signature                  :string
#  property_over_limit                :integer          default("unfilled"), not null
#  public_housing                     :integer          default("unfilled"), not null
#  raw_direct_file_data               :text
#  referrer                           :string
#  residence_county                   :string
#  routing_number                     :string
#  sales_use_tax                      :integer
#  sales_use_tax_calculation_method   :integer          default("unfilled"), not null
#  school_district                    :string
#  school_district_number             :integer
#  sign_in_count                      :integer          default(0), not null
#  source                             :string
#  spouse_birth_date                  :date
#  spouse_esigned                     :integer          default("unfilled"), not null
#  spouse_esigned_at                  :datetime
#  spouse_first_name                  :string
#  spouse_last_name                   :string
#  spouse_middle_initial              :string
#  spouse_signature                   :string
#  untaxed_out_of_state_purchases     :integer          default("unfilled"), not null
#  withdraw_amount                    :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  federal_submission_id              :string
#  primary_state_id_id                :bigint
#  school_district_id                 :integer
#  spouse_state_id_id                 :bigint
#  visitor_id                         :string
#
# Indexes
#
#  index_state_file_ny_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_ny_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_ny_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#

require "rails_helper"

describe StateFileNyIntake do
  it_behaves_like :state_file_base_intake, factory: :state_file_ny_intake

  describe "before_save" do
    let(:intake) { create :state_file_ny_intake, untaxed_out_of_state_purchases: "yes", sales_use_tax_calculation_method: "manual", sales_use_tax: "350" }

    context "when untaxed_out_of_state_purchases changes to no" do
      it "clears sales use tax calculation method and sales use tax" do
        expect {
          intake.update(untaxed_out_of_state_purchases: "no")
        }.to change(intake, :sales_use_tax_calculation_method).to("unfilled")
                                                              .and change(intake, :sales_use_tax).to(nil)
      end
    end

    context "when sales_use_tax_calculation_method changes to automated" do
      before do
        intake.direct_file_data.fed_agi = 102_000
      end
      it "calculates sales use tax" do
        expect {
          intake.update(sales_use_tax_calculation_method: "automated")
        }.to change(intake, :sales_use_tax).to(26)
      end
    end

    context "when payment_or_deposit_type changes to mail" do
      let!(:intake) do
        create :state_file_ny_intake,
               payment_or_deposit_type: "direct_deposit",
               account_type: "checking",
               bank_name: "Wells Fargo",
               routing_number: "123456789",
               account_number: "123",
               withdraw_amount: 123,
               date_electronic_withdrawal: Date.parse("April 1, 2023")
      end

      it "clears other account fields" do
        expect {
          intake.update(payment_or_deposit_type: "mail")
        }.to change(intake.reload, :account_type).to("unfilled")
        .and change(intake.reload, :bank_name).to(nil)
        .and change(intake.reload, :routing_number).to(nil)
        .and change(intake.reload, :account_number).to(nil)
        .and change(intake.reload, :withdraw_amount).to(nil)
        .and change(intake.reload, :date_electronic_withdrawal).to(nil)
      end
    end

    context "when enum that has unfilled type is set to nil" do
      let(:intake) { create :state_file_ny_intake, eligibility_yonkers: "yes", account_type: "checking" }
      it "saves as unfilled" do
        expect {
          intake.update(eligibility_yonkers: nil, account_type: nil)
        }.to change(intake.reload, :eligibility_yonkers).to("unfilled")
        .and change(intake.reload, :account_type).to("unfilled")
      end
    end
  end

  describe "#calculate_sales_use_tax" do
    context "when there is direct file data" do
      let(:intake) { build :state_file_ny_intake }
      let(:fed_agi) { 14_000 }
      before do
        intake.direct_file_data.fed_agi = fed_agi
      end

      context "when the federal agi is 14,000" do
        it "returns 3" do
          expect(intake.calculate_sales_use_tax).to eq 3
        end
      end

      context "when the federal agi is 75,001" do
        let(:fed_agi) { 75_001 }
        it "returns 18" do
          expect(intake.calculate_sales_use_tax).to eq 18
        end
      end

      context "when the federal agi is 201,000" do
        let(:fed_agi) { 201_000 }
        it "returns calculation" do
          expect(intake.calculate_sales_use_tax).to eq (201_000 * 0.000165).round
        end
      end

      context "when the federal agi is 700,000" do
        let(:fed_agi) { 800_000 }
        it "returns 125" do
          expect(intake.calculate_sales_use_tax).to eq 125
        end
      end
    end
  end

  describe "#ask_spouse_name?" do
    context "when married filing jointly" do
      it "returns true" do
        intake = build(:state_file_ny_intake, filing_status: "married_filing_jointly")
        expect(intake.ask_spouse_name?).to eq true
      end
    end

    context "when married filing separate" do
      it "returns true" do
        intake = build(:state_file_ny_intake, filing_status: "married_filing_separately")
        expect(intake.ask_spouse_name?).to eq false
      end
    end

    context "with any non-married filing status" do
      it "returns false" do
        intake = build(:state_file_ny_intake, filing_status: "head_of_household")
        expect(intake.ask_spouse_name?).to eq false
      end
    end
  end

  describe "#disqualifying_eligibility_answer" do
    it "returns nil when they haven't answered any questions yet" do
      intake = build(:state_file_ny_intake)
      expect(intake.disqualifying_eligibility_answer).to be_nil
    end

    it "returns :eligibility_lived_in_state when they haven't been a resident the whole year" do
      intake = build(:state_file_ny_intake, eligibility_lived_in_state: "no")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_lived_in_state
    end

    it "returns :eligibility_yonkers when they lived or worked in yonkers" do
      intake = build(:state_file_ny_intake, eligibility_yonkers: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_yonkers
    end

    it "returns :eligibility_out_of_state_income when they earned income in another state" do
      intake = build(:state_file_ny_intake, eligibility_out_of_state_income: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_out_of_state_income
    end

    it "returns :eligibility_part_year_nyc_resident when they were a part year nyc resident" do
      intake = build(:state_file_ny_intake, eligibility_part_year_nyc_resident: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_part_year_nyc_resident
    end

    it "returns :eligibility_withdrew_529 when they withdrew from a 529 account" do
      intake = build(:state_file_ny_intake, eligibility_withdrew_529: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_withdrew_529
    end

    it "returns :nyc_residency when they were a part year resident" do
      intake = build(:state_file_ny_intake, nyc_residency: "part_year")
      expect(intake.disqualifying_eligibility_answer).to eq :nyc_residency
    end

    it "returns :nyc_maintained_home when they maintained a home in nyc" do
      intake = build(:state_file_ny_intake, nyc_maintained_home: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :nyc_maintained_home
    end
  end

  describe "#has_disqualifying_eligibility_answer?" do
    it "returns false when they haven't answered any questions yet" do
      intake = build(:state_file_ny_intake)
      expect(intake.has_disqualifying_eligibility_answer?).to eq false
    end

    it "returns true when they haven't been a resident the whole year" do
      intake = build(:state_file_ny_intake, eligibility_lived_in_state: "no")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they lived or worked in yonkers" do
      intake = build(:state_file_ny_intake, eligibility_yonkers: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they earned income in another state" do
      intake = build(:state_file_ny_intake, eligibility_out_of_state_income: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they were a part year nyc resident" do
      intake = build(:state_file_ny_intake, eligibility_part_year_nyc_resident: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they withdrew from a 529 account" do
      intake = build(:state_file_ny_intake, eligibility_withdrew_529: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they were a part year resident" do
      intake = build(:state_file_ny_intake, nyc_residency: "part_year")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they maintained a home in nyc" do
      intake = build(:state_file_ny_intake, nyc_maintained_home: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end
  end

  describe "#ach_debit_transaction?" do
    let(:payment_or_deposit_type) { "direct_deposit" }
    let(:intake) { build :state_file_ny_intake, payment_or_deposit_type: payment_or_deposit_type }

    context "when they owe taxes and selected direct debit payment option" do
      before do
        allow(intake).to receive(:refund_or_owe_taxes_type).and_return(:owe)
      end

      it "returns true" do
        expect(intake.ach_debit_transaction?).to eq true
      end
    end

    context "when they have a refund and selected direct deposit payment option" do
      before do
        allow(intake).to receive(:refund_or_owe_taxes_type).and_return(:refund)
      end

      it "returns false" do
        expect(intake.ach_debit_transaction?).to eq false
      end
    end
  end

  describe "#disqualifying_df_data_reason" do
    let(:intake) { create :state_file_ny_intake }

    it "returns has_irc_125_code when direct file data has an IRC 125 amount in their W2 box 14" do
      w2 = intake.direct_file_data.w2_nodes.first
      box_14 = w2.at("AllocatedTipsAmt").add_next_sibling("<OtherDeductionsBenefitsGrp/>").first
      box_14.add_child("<Desc>IRC125S</Desc>")
      box_14.add_child("<Amount>999</Amount>")

      expect(intake.disqualifying_df_data_reason).to eq :has_irc_125_code
    end

    it "returns has_yonkers_income when direct file data has a Yonkers code in their W2 box 14" do
      w2 = intake.direct_file_data.w2_nodes.first
      box_14 = w2.at("AllocatedTipsAmt").add_next_sibling("<OtherDeductionsBenefitsGrp/>").first
      box_14.add_child("<Desc>YNK</Desc>")
      box_14.add_child("<Amount>999</Amount>")

      expect(intake.disqualifying_df_data_reason).to eq :has_yonkers_income
    end

    it "returns has_yonkers_income when direct file data has a Yonkers code in their W2 box 20" do
      w2 = intake.direct_file_data.w2_nodes.first
      state_tax_group = w2.at("W2StateLocalTaxGrp W2StateTaxGrp")
      local_tax_group = state_tax_group.add_child("<W2LocalTaxGrp/>").first
      local_tax_group.add_child("<LocalityNm>CITYOF YK</LocalityNm>")

      expect(intake.disqualifying_df_data_reason).to eq :has_yonkers_income
    end

    it "returns nil when direct file data has no disqualifying fields" do
      expect(intake.disqualifying_df_data_reason).to be_nil
    end

    it "returns has_out_of_state_w2 when direct file data has an out of state W2" do
      w2 = intake.direct_file_data.w2_nodes.first
      state_abbreviation_cd = w2.at("W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd")
      state_abbreviation_cd.inner_html = "UT"

      expect(intake.disqualifying_df_data_reason).to eq :has_out_of_state_w2
    end
  end
end
