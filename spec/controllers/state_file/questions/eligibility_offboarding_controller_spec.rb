require 'rails_helper'

RSpec.describe StateFile::Questions::EligibilityOffboardingController do
  describe ".show?" do
    context "when the intake has a disqualifying answer" do
      it "returns true" do
        intake = double("intake", has_disqualifying_eligibility_answer?: true)
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the intake does not have a disqualifying answer" do
      it "returns false" do
        intake = double("intake", has_disqualifying_eligibility_answer?: false)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    context "with offboarded_from set in the session" do
      let(:intake) { create :state_file_id_intake }

      render_views
      let(:offboarded_from_path) do
        StateFile::Questions::IdEligibilityResidenceController.to_path_helper
      end
      before do
        sign_in intake
        session[:offboarded_from] = offboarded_from_path
      end

      it "uses the correct prev_path for the Go back button" do
        get :edit

        expect(Nokogiri::HTML.parse(response.body)).to have_link(href: offboarded_from_path)
        expect(session[:offboarded_from]).to be_nil
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
