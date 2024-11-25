require "rails_helper"

RSpec.describe StateFile::Questions::MdReviewController do
  let(:intake) { create :state_file_md_intake}

  before do
    sign_in intake
  end
  describe "#edit" do
    render_views

    it "renders" do
      get :edit
      expect(response).to be_successful
    end

    it "shows detailed return information" do
      intake.direct_file_data.fed_agi = 22_112
      intake.direct_file_data.fed_taxable_ssb = 1_000
      intake.direct_file_data.fed_taxable_income = 3_000
      intake.calculator.lines[:MD502_DEDUCTION_METHOD].instance_variable_set(:@value, "S")
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_3).and_return(3_333)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_10a).and_return(123)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_u).and_return(85)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_v).and_return(144)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_ab).and_return(42)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_16).and_return(19_026)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_17).and_return(1_117)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_19).and_return(2_987)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_20).and_return(21_456)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_21).and_return(2_488)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return(874)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_23).and_return(454)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_md502_cr_part_b_line_4).and_return(512)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_md502_cr_part_m_line_1).and_return(449)


      intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)

      get :edit

      page_content = response.body

      expect(page_content).to include I18n.t("state_file.general.see_detailed_return")
      expect(page_content).to include I18n.t("state_file.general.md_return_type")
      expect(page_content).to include I18n.t("state_file.general.md_type_of_return_standard")
      expect(page_content).to include I18n.t("state_file.general.fed_agi")
      expect(page_content).to include "$22,112"
      expect(page_content).to include I18n.t("state_file.general.md_state_retirement_pickup_addition")
      expect(page_content).to include "$3,333"
      # TODO: add this once lines 9 are implemented
      # expect(page_content).to include I18n.t("state_file.general.md_subtraction_child_dependent_care_expenses")
      # expect(page_content).to include "$0"
      expect(page_content).to include I18n.t("state_file.general.md_pension_income_exclusion")
      expect(page_content).to include "$123"
      # TODO: add this once lines 11 are implemented
      # expect(page_content).to include I18n.t("state_file.general.md_social_security_income_not_taxed")
      # expect(page_content).to include "$0"
      expect(page_content).to include I18n.t("state_file.general.md_military_retirement_income_exclusion")
      expect(page_content).to include "$85"
      expect(page_content).to include I18n.t("state_file.general.md_public_safety_retirement_income_exclusion")
      expect(page_content).to include "$144"
      expect(page_content).to include I18n.t("state_file.general.md_subtraction_income_us_gov_bonds")
      expect(page_content).to include "$42"
      # TODO: add this once lines 14 are implemented
      # expect(page_content).to include I18n.t("state_file.general.md_two_income_subtraction_married_taxpayers")
      # expect(page_content).to include "$0"
      expect(page_content).to include I18n.t("state_file.general.md_adjusted_gross_income")
      expect(page_content).to include "$19,026"
      expect(page_content).to include I18n.t("state_file.general.md_standard_deduction")
      expect(page_content).to include "$1,117"
      expect(page_content).to include I18n.t("state_file.general.md_total_exemptions_people_household")
      expect(page_content).to include "$2,987"
      expect(page_content).to include I18n.t("state_file.general.md_taxable_net_income")
      expect(page_content).to include "$21,456"
      expect(page_content).to include I18n.t("state_file.general.md_tax")
      expect(page_content).to include "$2,488"
      expect(page_content).to include I18n.t("state_file.general.md_tax")
      expect(page_content).to include "$2,488"
      expect(page_content).to include I18n.t("state_file.general.md_nonrefundable_earned_income_tax_credit")
      expect(page_content).to include "$874"
      expect(page_content).to include I18n.t("state_file.general.md_poverty_level_credit")
      expect(page_content).to include "$454"
      expect(page_content).to include I18n.t("state_file.general.md_nonrefundable_credit_child_dependent_care")
      expect(page_content).to include "$512"
      expect(page_content).to include I18n.t("state_file.general.md_senior_tax_credit")
      expect(page_content).to include "$449"
      # TODO: add this once lines 28, 29, 30, 34 are implemented
      # expect(page_content).to include I18n.t("state_file.general.md_local_tax")
      # expect(page_content).to include "$0"
      # expect(page_content).to include I18n.t("state_file.general.md_nonrefundable_local_earned_income_tax_credit")
      # expect(page_content).to include "$0"
      # expect(page_content).to include I18n.t("state_file.general.md_local_poverty_level_credit")
      # expect(page_content).to include "$0"
      # expect(page_content).to include I18n.t("state_file.general.md_total_tax_after_nonrefundable_credits")
      expect(page_content).to include I18n.t("state_file.general.md_tax_withheld")
      expect(page_content).to include "$449"
      # TODO: add this once lines 42, 44, CR part CC line 7 and CR part CC line 8 are implemented
      # expect(page_content).to include I18n.t("state_file.general.md_refundable_earned_income_tax_credit")
      # expect(page_content).to include "$0"
      # expect(page_content).to include I18n.t("state_file.general.md_refundable_child_dependent_care_credit")
      # expect(page_content).to include "$0"
      # expect(page_content).to include I18n.t("state_file.general.md_child_tax_credit")
      # expect(page_content).to include "$0"
      # expect(page_content).to include I18n.t("state_file.general.md_total_payments_refundable_credits")
      # # expect(page_content).to include "$0"
    end
  end
end