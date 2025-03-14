require "rails_helper"

RSpec.describe StateFile::Questions::NjOverpaymentsController do
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

    describe "#update" do
      context "when a user has overpayments" do
        let(:form_params) {
          {
            state_file_nj_overpayments_form: {
              has_overpayments: "yes",
              overpayments: 1000
            }
          }
        }

        it "saves the correct value for renter" do
          post :update, params: form_params
          intake.reload
          expect(intake.has_overpayments).to eq "yes"
          expect(intake.overpayments).to eq 1000
        end
      end

      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            state_file_nj_overpayments_form: {
              has_overpayments: "yes",
              overpayments: 1000,
            }
          }
        end
      end
    end
  end
end