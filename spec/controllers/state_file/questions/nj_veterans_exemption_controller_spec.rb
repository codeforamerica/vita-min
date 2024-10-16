require "rails_helper"

RSpec.describe StateFile::Questions::NjVeteransExemptionController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context "when a user is MFJ" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly }

      it "shows the spouse_veteran checkbox" do
        get :edit
        expect(response.body).to include("Is your spouse a veteran?")
      end
    end

    context "when a user is not MFJ" do
      let(:intake) { create :state_file_nj_intake }

      it "does not show the spouse_veteran checkbox" do
        get :edit
        expect(response.body).not_to include("Is your spouse a veteran?")
      end
    end
  end

  describe "#update" do
    context "with a valid selection" do
      let(:form_params) {
        {
          state_file_nj_veterans_exemption_form: {
            primary_veteran: "yes",
            spouse_veteran: "no"
          }
        }
      }

      it "saves the correct veterans statuses" do
        post :update, params: form_params

        intake.reload
        expect(intake.primary_veteran_yes?).to eq true
        expect(intake.spouse_veteran_no?).to eq true
      end
    end
  end
end