# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                                 :bigint           not null, primary key
#  account_number                     :string
#  account_type                       :integer          default("unfilled"), not null
#  amount_electronic_withdrawal       :integer
#  amount_owed_pay_electronically     :integer          default("unfilled"), not null
#  claimed_as_dep                     :integer          default("unfilled"), not null
#  confirmed_permanent_address        :integer          default("unfilled"), not null
#  contact_preference                 :integer          default("unfilled"), not null
#  current_step                       :string
#  date_electronic_withdrawal         :date
#  eligibility_lived_in_state         :integer          default("unfilled"), not null
#  eligibility_out_of_state_income    :integer          default("unfilled"), not null
#  eligibility_part_year_nyc_resident :integer          default("unfilled"), not null
#  eligibility_withdrew_529           :integer          default("unfilled"), not null
#  eligibility_yonkers                :integer          default("unfilled"), not null
#  email_address                      :citext
#  email_address_verified_at          :datetime
#  esigned_return                     :integer          default("unfilled"), not null
#  esigned_return_at                  :datetime
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
#  mailing_country                    :string
#  mailing_state                      :string
#  nursing_home                       :integer          default("unfilled"), not null
#  ny_414h_retirement                 :integer
#  ny_mailing_apartment               :string
#  ny_mailing_city                    :string
#  ny_mailing_street                  :string
#  ny_mailing_zip                     :string
#  ny_other_additions                 :integer
#  nyc_full_year_resident             :integer          default("unfilled"), not null
#  occupied_residence                 :integer          default("unfilled"), not null
#  permanent_apartment                :string
#  permanent_city                     :string
#  permanent_street                   :string
#  permanent_zip                      :string
#  phone_number                       :string
#  phone_number_verified_at           :datetime
#  primary_birth_date                 :date
#  primary_email                      :string
#  primary_first_name                 :string
#  primary_last_name                  :string
#  primary_middle_initial             :string
#  primary_signature                  :string
#  property_over_limit                :integer          default("unfilled"), not null
#  public_housing                     :integer          default("unfilled"), not null
#  raw_direct_file_data               :text
#  referrer                           :string
#  refund_choice                      :integer          default("unfilled"), not null
#  residence_county                   :string
#  routing_number                     :string
#  sales_use_tax                      :integer
#  sales_use_tax_calculation_method   :integer          default("unfilled"), not null
#  school_district                    :string
#  school_district_number             :integer
#  source                             :string
#  spouse_birth_date                  :date
#  spouse_first_name                  :string
#  spouse_last_name                   :string
#  spouse_middle_initial              :string
#  spouse_signature                   :string
#  untaxed_out_of_state_purchases     :integer          default("unfilled"), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  primary_state_id_id                :bigint
#  spouse_state_id_id                 :bigint
#  visitor_id                         :string
#
# Indexes
#
#  index_state_file_ny_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_ny_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#

require "rails_helper"

describe StateFileNyIntake do
  it_behaves_like :state_file_base_intake, factory: :state_file_ny_intake

  describe "before_save" do
    let(:intake) { create :state_file_ny_intake, untaxed_out_of_state_purchases: "yes", sales_use_tax_calculation_method: "manual", sales_use_tax: "350", household_fed_agi: 102_000 }

    context "when untaxed_out_of_state_purchases changes to no" do
      it "clears sales use tax calculation method and sales use tax" do
        expect {
          intake.update(untaxed_out_of_state_purchases: "no")
        }.to change(intake, :sales_use_tax_calculation_method).to("unfilled")
         .and change(intake, :sales_use_tax).to(nil)
      end
    end

    context "when sales_use_tax_calculation_method changes to automated" do
      it "calculates sales use tax" do
        expect {
          intake.update(sales_use_tax_calculation_method: "automated")
        }.to change(intake, :sales_use_tax).to(29)
      end
    end

  end

  describe "#calculate_sales_use_tax" do
    let(:intake) { build :state_file_ny_intake, household_fed_agi: household_fed_agi }
    let(:household_fed_agi) { 14_000 }

    context "when the federal agi is 14,000" do
      it "returns 3" do
        expect(intake.calculate_sales_use_tax).to eq 3
      end
    end

    context "when the federal agi is 75,001" do
      let(:household_fed_agi) { 75_001 }
      it "returns 23" do
        expect(intake.calculate_sales_use_tax).to eq 23
      end
    end

    context "when the federal agi is 201,000" do
      let(:household_fed_agi) { 201_000 }
      it "returns calculation" do
        expect(intake.calculate_sales_use_tax).to eq (201_000 * 0.000195).round
      end
    end

    context "when the federal agi is 700,000" do
      let(:household_fed_agi) { 700_000 }
      it "returns 125" do
        expect(intake.calculate_sales_use_tax).to eq 125
      end
    end

    context "when the federal agi is nil" do
      let(:household_fed_agi) { nil }
      it "returns nil" do
        expect(intake.calculate_sales_use_tax).to eq nil
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
        expect(intake.ask_spouse_name?).to eq true
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
  end
end
