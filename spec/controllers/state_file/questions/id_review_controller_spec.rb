require "rails_helper"

RSpec.describe StateFile::Questions::IdReviewController do
  let(:intake) { create :state_file_id_intake}

  before do
    sign_in intake
  end
  describe "#edit" do
    render_views

    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
    end

    it "renders" do
      get :edit
      expect(response).to be_successful
    end

    it "shows detailed return information" do
      intake.direct_file_data.fed_agi = 20_000
      intake.direct_file_data.fed_taxable_ssb = 1_000
      intake.direct_file_data.fed_taxable_income = 3_000
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_7).and_return(25_000)
      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_6).and_return(1_000)
      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_18).and_return(400)
      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_7).and_return(8_000)
      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_3).and_return(400)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_11).and_return(23_500)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_16).and_return(500)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_19).and_return(600)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_20).and_return(700)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_25).and_return(2_500)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_29).and_return(275)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_32a).and_return(10)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_33).and_return(3_225)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_46).and_return(1_000)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_43).and_return(343)
      allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_50).and_return(20_000)

      intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)

      get :edit

      page_content = response.body

      expect(page_content).to include I18n.t("state_file.general.see_detailed_return")
      expect(page_content).to include I18n.t("state_file.general.fed_agi")
      expect(page_content).to include "$25,000"
      expect(page_content).to include I18n.t("state_file.general.id_health_insurance")
      expect(page_content).to include "$400"
      expect(page_content).to include I18n.t("state_file.general.id_social_security_income")
      expect(page_content).to include "$8,000"
      expect(page_content).to include I18n.t("state_file.general.id_retirement_benefits")
      expect(page_content).to include "$0"
      expect(page_content).to include I18n.t("state_file.general.id_interest_income")
      expect(page_content).to include "$400"
      expect(page_content).to include I18n.t("state_file.general.id_adjusted_income")
      expect(page_content).to include "$23,500"
      expect(page_content).to include I18n.t("state_file.general.id_standard_deduction")
      expect(page_content).to include "$500"
      expect(page_content).to include I18n.t("state_file.general.id_taxable_income")
      expect(page_content).to include "$600"
      expect(page_content).to include I18n.t("state_file.general.id_tax")
      expect(page_content).to include "$700"
      expect(page_content).to include I18n.t("state_file.general.id_child_tax_credit")
      expect(page_content).to include "$2,500"
      expect(page_content).to include I18n.t("state_file.general.id_use_tax")
      expect(page_content).to include "$275"
      expect(page_content).to include I18n.t("state_file.general.id_building_fund_tax")
      expect(page_content).to include "$10"
      expect(page_content).to include I18n.t("state_file.general.id_tax_after_credits")
      expect(page_content).to include "$3,225"
      expect(page_content).to include I18n.t("state_file.general.id_tax_withheld")
      expect(page_content).to include "$1,000"
      expect(page_content).to include I18n.t("state_file.general.id_grocery_credit")
      expect(page_content).to include "$343"
      expect(page_content).to include I18n.t("state_file.general.id_total_payments")
      expect(page_content).to include "$20,000"
    end
  end
end
