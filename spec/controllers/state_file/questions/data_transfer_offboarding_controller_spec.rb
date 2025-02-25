require "rails_helper"

RSpec.describe StateFile::Questions::DataTransferOffboardingController do
  describe "#edit" do
    let(:intake) { create :state_file_az_intake, filing_status: filing_status }
    let(:filing_status) { :single }

    before do
      sign_in intake
    end

    context "when the client's Direct File data disqualifies them" do
      let(:filing_status) { :married_filing_separately }

      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to eq(I18n.t('state_file.questions.data_transfer_offboarding.edit.ineligible_reason.married_filing_separately'))
      end
    end

    context "when the client is eligible" do
      it "gets the correct values for ineligible_reason" do
        expect(subject.ineligible_reason).to be_nil
      end
    end

    shared_examples "check for NJ-specific content" do |current_state_code, show_nj_content|
      let(:intake) { create "state_file_#{current_state_code}_intake" }
      render_views
      before do
        sign_in intake
      end

      it "checks for NJ-specific content" do
        get :edit
        if show_nj_content
          expect(response.body).to have_text I18n.t("state_file.questions.eligible.vita_option.connect_to_vita")
          expect(response.body).to have_text I18n.t("state_file.questions.eligible.vita_option.vita_introduction.nj")
        else
          expect(response.body).not_to have_text I18n.t("state_file.questions.eligible.vita_option.connect_to_vita")
          expect(response.body).not_to have_text I18n.t("state_file.questions.eligible.vita_option.vita_introduction.nj")
        end
      end
    end

    context "AZ" do
      it_behaves_like "check for NJ-specific content", "az", false
    end

    context "ID" do
      it_behaves_like "check for NJ-specific content", "id", false
    end

    context "MD" do
      it_behaves_like "check for NJ-specific content", "md", false
    end

    context "NJ" do
      it_behaves_like "check for NJ-specific content", "nj", true
    end
  end
end
