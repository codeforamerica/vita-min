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

    context 'when the extension_period Flipper flag is set' do
      before do
        allow(Flipper).to receive(:enabled?).with(:hide_intercom).and_return(true)
        allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(true)
      end

      it 'displays the extension_payments field' do
        get :edit
        expect(response.body).to include(I18n.t('state_file.questions.nj_estimated_tax_payments.edit.extension_payments_input_helper_html', current_year: Rails.configuration.statefile_current_tax_year+1))
      end

      it('displays the extensions-specific description content') do
        get :edit
        expect(response.body).to include("An additional payment you made when you")
      end
    end

    context 'when the extension_period Flipper flag is NOT set' do
      before do
        allow(Flipper).to receive(:enabled?).with(:hide_intercom).and_return(true)
        allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(false)
      end

      it 'does not display the extension_payments field' do
        get :edit
        expect(response.body).not_to include(I18n.t('state_file.questions.nj_estimated_tax_payments.edit.extension_payments_input_helper_html', current_year: Rails.configuration.statefile_current_tax_year+1))
      end

      it('does not display the extensions-specific description content') do
        get :edit
        expect(response.body).not_to include("An additional payment you made when you")
      end
    end

    describe "#update" do
      context "when a user has estimated tax payments, overpayments, and extension payments" do
        let(:form_params) {
          {
            state_file_nj_estimated_tax_payments_form: {
              has_estimated_payments: "yes",
              estimated_tax_payments: 1000,
              overpayments: 2000,
              extension_payments: 500
            }
          }
        }

        it "saves the correct value for renter" do
          post :update, params: form_params
          intake.reload
          expect(intake.has_estimated_payments).to eq "yes"
          expect(intake.estimated_tax_payments).to eq 1000
          expect(intake.overpayments).to eq 2000
          expect(intake.extension_payments).to eq 500
        end
      end

      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            state_file_nj_estimated_tax_payments_form: {
              has_estimated_payments: "yes",
              estimated_tax_payments: 1000,
              overpayments: 2000,
              extension_payments: 500
            }
          }
        end
      end
    end
  end
end