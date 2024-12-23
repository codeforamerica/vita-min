require "rails_helper"

RSpec.describe StateFile::Questions::NjEstimatedTaxPaymentsController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#prev_path" do
    it "routes to household_rent_own" do
      expect(subject.prev_path).to eq(StateFile::Questions::NjHouseholdRentOwnController.to_path_helper)
    end
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    describe "#update" do
      context "when a user has estimated tax payments" do
        let(:form_params) {
          {
            state_file_nj_estimated_tax_payments_form: {
              estimated_tax_payments: 1000,
            }
          }
        }

        it "saves the correct value for renter" do
          post :update, params: form_params
          intake.reload
          expect(intake.estimated_tax_payments).to eq 1000
        end
      end

      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            state_file_nj_estimated_tax_payments_form: {
              estimated_tax_payments: 1000,
            }
          }
        end
      end
    end
  end
end