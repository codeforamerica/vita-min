require "rails_helper"

RSpec.describe StateFile::Questions::NyReviewController, skip: true do
  describe "#edit" do
    before do
      sign_in intake
    end

    context "when the client is estimated to owe taxes" do
      # Not being an NYC full year resident and increased unemployment contributions result in owed amount
      let(:intake) { create :state_file_ny_owed_intake }

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit

        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.shared.review_header.your_tax_owed")
      end
    end

    context "when the client is estimated to get a refund" do
      let(:intake) { create :state_file_ny_refund_intake }

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit

        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.shared.review_header.your_refund")
      end
    end

    context "when a dependent is present" do
      render_views
      let(:intake) { create :state_file_ny_refund_intake }
      let!(:dependent) { create :state_file_dependent, intake: intake, dob: 7.years.ago, first_name: "Bobby", middle_initial: nil, last_name: "Tables", relationship: "biologicalChild" }

      it "displayed dependent details" do
        get :edit
        expect(response.body).to include I18n.t("state_file.questions.shared.abstract_review_header.dependent_dob")
        expect(response.body).to include "Bobby Tables"
        expect(response.body).not_to include I18n.t("state_file.questions.shared.abstract_review_header.dependent_months_in_home")
      end
    end
  end
end
