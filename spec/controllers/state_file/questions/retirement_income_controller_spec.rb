require "rails_helper"

RSpec.describe StateFile::Questions::RetirementIncomeController do
  let(:intake) { create :state_file_az_intake, filing_status: :married_filing_jointly, spouse_first_name: "Glenn", spouse_last_name: "Gary" }
  before do
    sign_in intake
  end

  describe "#edit" do
    let(:client) { intake.client }
    let!(:form1099r) do
      create :state_file1099_r,
             payer_name: "Ace Hardware",
             recipient_name: "Phoenix Wright",
             payer_state_identification_number: '123456669',
             state_distribution_amount: 1000,
             state_tax_withheld_amount: 100,
             intake: intake
    end
    let(:params) { { id: form1099r.id } }

    render_views

    it "renders information about the existing retirement income" do
      get :edit, params: params

      expect(response.body).to include("Ace Hardware")
      expect(response.body).to include("Phoenix Wright")
      expect(response.body).to include("123456669")
      expect(response.body).to include("1000")
      expect(response.body).to include("100")
    end
  end

  describe "#update" do
    let!(:form1099r) do
      create :state_file1099_r,
             intake: intake
    end
    let(:params) do
      {
        id: form1099r.id,
        state_file1099_r: {
          state_distribution_amount: 2011,
          payer_state_identification_number: 'Az3456789',
          state_tax_withheld_amount: 50
        }
      }
    end

    it "updates the 1099R information and redirects to the income review page" do
      post :update, params: params

      expect(response).to redirect_to(edit_income_review_path(id: params[:id]))

      form1099r.reload
      expect(form1099r.state_distribution_amount).to eq 2011
      expect(form1099r.payer_state_identification_number).to eq 'Az3456789'
      expect(form1099r.state_tax_withheld_amount).to eq 50
    end

    context "with invalid params" do
      render_views

      let(:params) do
        {
          id: form1099r.id,
          state_file1099_r: {
            state_distribution_amount: '',
            state_tax_withheld_amount: '-10',
            payer_state_identification_number: '123456789'
          }
        }
      end

      it "renders edit with validation errors" do
        expect do
          post :update, params: params
        end.not_to change(StateFile1099R, :count)

        expect(response).to render_template(:edit)

        expect(response.body).to include "is not a number"
        expect(response.body).to include "must be greater than or equal to 0"
        expect(response.body).to include "First two letters must be az"
      end
    end
  end
end
