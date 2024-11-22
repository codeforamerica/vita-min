require "rails_helper"

RSpec.describe StateFile::Questions::NcReviewController do
  let(:intake) { create :state_file_nc_intake }

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
      intake.direct_file_data.fed_agi = 20_000
      intake.direct_file_data.fed_taxable_ssb = 1_000
      intake.direct_file_data.fed_taxable_income = 3_000
      allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_27).and_return(150)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_10b).and_return(550)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_11).and_return(1_700)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_14).and_return(19_000)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_15).and_return(2_001)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_18).and_return(2)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_19).and_return(2_004)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20a).and_return(1_010)
      allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20b).and_return(1_020)
      intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)

      get :edit

      page_content = response.body
      expect(page_content).to include I18n.t("state_file.general.see_detailed_return")
      expect(page_content).to include I18n.t("state_file.general.fed_agi")
      expect(page_content).to include "$20,000"
      expect(page_content).to include I18n.t("state_file.questions.nc_review.edit.social_security_benefits")
      expect(page_content).to include "$1,000"
      expect(page_content).to include I18n.t("state_file.questions.nc_review.edit.interest_us_bonds")
      expect(page_content).to include "$3,000"
      # TODO: add this once lines 20 & 21 are implemented
      # Subtraction for retirement benefits by vested qualifying government pensions
      # [schedule S, line 20]
      # Subtraction for retirement benefits received by service members
      # [schedule S, line 21]

      expect(page_content).to include I18n.t("state_file.questions.nc_review.edit.subtraction_indian_tribe")
      expect(page_content).to include "$150"
      expect(page_content).to include I18n.t("state_file.questions.nc_review.edit.child_deduction")
      expect(page_content).to include "$550"
      expect(page_content).to include I18n.t("state_file.general.standard_deduction")
      expect(page_content).to include "$1,700"
      expect(page_content).to include I18n.t("state_file.general.nc_taxable_income")
      expect(page_content).to include "$19,000"
      expect(page_content).to include I18n.t("state_file.general.nc_income_tax")
      expect(page_content).to include "$2,001"
      expect(page_content).to include I18n.t("state_file.general.nc_use_tax")
      expect(page_content).to include "$2"
      expect(page_content).to include I18n.t("state_file.general.total_tax")
      expect(page_content).to include "$2,004"
      expect(page_content).to include I18n.t("state_file.general.nc_tax_withheld")
      expect(page_content).to include "$2,030" # lines 20a + 20b
    end
  end
end