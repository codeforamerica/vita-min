require "rails_helper"

RSpec.describe StateFile::Questions::NyReviewController do
  describe "#edit" do
    context "when the client is estimated to owe taxes" do
      # Not being an NYC full year resident and increased unemployment contributions result in owed amount
      let(:intake) { create :state_file_ny_owed_intake}
      before do
        session[:state_file_intake] = intake.to_global_id
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit, params: { us_state: "ny" }

        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.shared.review_header.your_tax_owed")
      end
    end

    context "when the client is estimated to get a refund" do
      # The default fixtures result in an expected refund
      let(:intake) { create :state_file_ny_intake }
      before do
        session[:state_file_intake] = intake.to_global_id
      end

      it "assigns the correct values to @refund_or_tax_owed_label and @refund_or_owed_amount" do
        get :edit, params: { us_state: "ny" }

        refund_or_owed_label = assigns(:refund_or_owed_label)
        expect(refund_or_owed_label).to eq I18n.t("state_file.questions.shared.review_header.your_refund")
      end
    end
  end
end