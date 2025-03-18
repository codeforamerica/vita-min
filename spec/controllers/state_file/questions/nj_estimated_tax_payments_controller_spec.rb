require "rails_helper"

RSpec.describe StateFile::Questions::NjEstimatedTaxPaymentsController do
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
      context "when a user has estimated tax payments and overpayments" do
        let(:form_params) {
          {
            state_file_nj_estimated_tax_payments_form: {
              has_estimated_payments: "yes",
              estimated_tax_payments: 1000,
              overpayments: 2000
            }
          }
        }

        it "saves the correct value for renter" do
          post :update, params: form_params
          intake.reload
          expect(intake.has_estimated_payments).to eq "yes"
          expect(intake.estimated_tax_payments).to eq 1000
          expect(intake.overpayments).to eq 2000
        end
      end

      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            state_file_nj_estimated_tax_payments_form: {
              has_estimated_payments: "yes",
              estimated_tax_payments: 1000,
              overpayments: 2000,
            }
          }
        end
      end
    end
  end
end