require "rails_helper"

RSpec.describe StateFile::Questions::AzReviewController do
  describe "#edit" do
    context "when the client is estimated to owe taxes" do
      # Default fixtures result in tax owed
      let(:intake) { create :state_file_az_intake }
      before do
        session[:state_file_intake] = intake.to_global_id
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit, params: { us_state: "az" }

        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.ny_review.edit.your_tax_owed")
      end
    end

    context "when the client is estimated to get a refund" do
      # This fixture sets a lower agi and results in an estimated refund
      let(:intake) { create :state_file_az_refund_intake }
      before do
        session[:state_file_intake] = intake.to_global_id
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        session[:state_file_intake] = intake.to_global_id

        get :edit, params: { us_state: "az" }

        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.ny_review.edit.your_refund")
      end
    end
  end
end