require "rails_helper"

RSpec.describe StateFile::Questions::AzReviewController do
  describe "#edit" do
    context "when the client is estimated to owe taxes" do
      # Higher adjusted agi to result in an owed amount
      let(:intake) { create :state_file_az_owed_intake}
      before do
        sign_in intake
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit, params: { us_state: "az" }

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

        get :edit, params: { us_state: "az" }

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

        get :edit, params: { us_state: "az" }
        expect(response.body).to include I18n.t("state_file.questions.az_review.edit.was_incarcerated")
        expect(response.body).to include I18n.t("state_file.questions.az_review.edit.household_excise_credit_claimed")
      end

      it "does not show the incarcerated question" do
        intake.update(raw_direct_file_data: intake.raw_direct_file_data.gsub!("10000", "20000"))
        sign_in intake

        get :edit, params: { us_state: "az" }
        expect(response.body).not_to include I18n.t("state_file.questions.az_review.edit.was_incarcerated")
        expect(response.body).not_to include I18n.t("state_file.questions.az_review.edit.ssn_no_employment")
        expect(response.body).not_to include I18n.t("state_file.questions.az_review.edit.household_excise_credit_claimed")
      end
    end
  end
end