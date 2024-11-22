require "rails_helper"

RSpec.describe StateFile::Questions::NjGubernatorialElectionsController do
  let(:intake) { create :state_file_nj_intake, primary_contribution_gubernatorial_elections: :yes, spouse_contribution_gubernatorial_elections: :yes}
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "when a mfj primary and spouse update their choice" do
      let(:form_params) {
        {
          state_file_nj_gubernatorial_elections_form: {
            primary_contribution_gubernatorial_elections: 'no',
            spouse_contribution_gubernatorial_elections: 'no'
          }
        }
      }

      it "saves the updated values" do
        post :update, params: form_params
        intake.reload
        expect(intake.primary_contribution_gubernatorial_elections).to eq 'no'
        expect(intake.spouse_contribution_gubernatorial_elections).to eq 'no'
      end
    end

    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_nj_gubernatorial_elections_form: {
            primary_contribution_gubernatorial_elections: 'no',
            spouse_contribution_gubernatorial_elections: 'no'
          }
        }
      end
    end
  end
end