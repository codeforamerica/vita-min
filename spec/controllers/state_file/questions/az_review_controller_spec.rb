require "rails_helper"

RSpec.describe StateFile::Questions::AzReviewController do
  describe "#edit" do
    context "when the client is estimated to owe taxes" do
      # Higher adjusted agi to result in an owed amount
      let(:intake) { create :state_file_az_owed_intake }
      before do
        sign_in intake
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit
        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.shared.review_header.your_tax_owed")
      end
    end

    context "when the client is estimated to get a refund" do
      # This fixture sets a lower agi and results in an estimated refund
      let(:intake) { create :state_file_az_refund_intake }
      before do
        sign_in intake
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit
        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.shared.review_header.your_refund")
      end
    end

    context "ask about incarceration" do
      render_views
      let(:intake) { create :state_file_az_refund_intake }
      before do
        sign_in intake
      end

      it "shows the incarcerated question" do
        get :edit
        expect(response.body).to include I18n.t("state_file.questions.az_review.edit.was_incarcerated", filing_year: Rails.configuration.statefile_current_tax_year)
        expect(response.body).to include I18n.t("state_file.questions.az_review.edit.household_excise_credit_claimed")
      end

      context "when primary answers no to was incarcerated question" do
        it "shows the answer being no" do
          get :edit
          expect(response.body).not_to include I18n.t("general.affirmative")
          expect(response.body).to include I18n.t("general.negative")
        end
      end

      context "when primary answers yes to was incarcerated question" do
        let(:intake) { create :state_file_az_refund_intake, primary_was_incarcerated: 'yes' }

        it "shows the answer being yes" do
          get :edit
          expect(response.body).to include I18n.t("general.affirmative")
        end
      end


      it "does not show the incarcerated question" do
        intake.update(raw_direct_file_data: intake.raw_direct_file_data.gsub!("10000", "20000"))
        sign_in intake

        get :edit
        expect(response.body).not_to include I18n.t("state_file.questions.az_review.edit.was_incarcerated", filing_year: Rails.configuration.statefile_current_tax_year)
        expect(response.body).not_to include I18n.t("state_file.questions.az_review.edit.ssn_no_employment")
        expect(response.body).not_to include I18n.t("state_file.questions.az_review.edit.household_excise_credit_claimed")
      end
    end

    context "when the client's return includes all calculations" do
      render_views
      let(:intake) { create :state_file_az_intake }

      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      end

      it "shows all relevant details" do
        intake.direct_file_data.fed_agi = 23_112
        intake.direct_file_data.fed_taxable_ssb = 1_000
        allow_any_instance_of(StateFileAzIntake).to receive(:total_exemptions).and_return(25)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_29A).and_return(5)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_29B).and_return(10)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_31).and_return(15)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_32).and_return(20)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_42).and_return(30)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_43).and_return(35)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_44).and_return(40)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_45).and_return(45)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_46).and_return(50)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_49).and_return(55)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_50).and_return(60)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_52).and_return(75)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_53).and_return(80)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_56).and_return(85)
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_59).and_return(90)

        allow_any_instance_of(Efile::Az::Az301Calculator).to receive(:calculate_line_6c).and_return(65)
        allow_any_instance_of(Efile::Az::Az301Calculator).to receive(:calculate_line_7c).and_return(70)
        intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
        sign_in intake
        get :edit
        page_content = response.body
        expect(page_content).to include I18n.t("state_file.general.fed_agi")
        expect(page_content).to include "$23,112"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.exclusion_for_govt_pensions")
        expect(page_content).to include "$5"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.exclusion_for_military_pensions")
        expect(page_content).to include "$10"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.ssn_not_taxed")
        expect(page_content).to include "$1,000"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.subtraction_for_indian_res")
        expect(page_content).to include "$15"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.subtraction_for_military_pay")
        expect(page_content).to include "$20"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.total_exemptions")
        expect(page_content).to include "$25"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.az_agi")
        expect(page_content).to include "$30"
        expect(page_content).to include I18n.t("state_file.general.standard_deduction")
        expect(page_content).to include "$35"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.incr_deduction_charity_contributions")
        expect(page_content).to include "$40"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.az_taxable_income")
        expect(page_content).to include "$45"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.az_tax")
        expect(page_content).to include "$50"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.dependent_tax_credit")
        expect(page_content).to include "$55"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.family_income_tax_credit")
        expect(page_content).to include "$60"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.credit_to_qualifying_charitable")
        expect(page_content).to include "$65"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.public_school_credit")
        expect(page_content).to include "$70"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.total_tax_nonrefundable_credits")
        expect(page_content).to include "$75"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.az_tax_withheld")
        expect(page_content).to include "$80"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.increased_excise_tax_credit")
        expect(page_content).to include "$85"
        expect(page_content).to include I18n.t("state_file.questions.az_review.edit.total_payments")
        expect(page_content).to include "$90"
      end
    end
  end
end
