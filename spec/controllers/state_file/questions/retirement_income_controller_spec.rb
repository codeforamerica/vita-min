require "rails_helper"

RSpec.describe StateFile::Questions::RetirementIncomeController do
  let(:intake) { create :state_file_az_intake, filing_status: :married_filing_jointly, spouse_first_name: "Glenn", spouse_last_name: "Gary" }
  before do
    sign_in intake
  end

  describe "#show" do
    let(:client) { intake.client }
    let!(:form1099r) do
      create :state_file1099_r,
             payer_name: "Ace Hardware",
             recipient_name: "Phoenix Wright",
             payer_state_identification_number: 'az123456669',
             state_distribution_amount: 30,
             state_tax_withheld_amount: 40,
             intake: intake
    end
    let(:params) { { id: form1099r.id } }

    render_views

    it "renders information about the existing retirement income" do
      get :show, params: params

      expect(response.body).to include("Ace Hardware")
      expect(response.body).to include("Phoenix Wright")
      expect(response.body).to include("az123456669")
      expect(response.body).to include("30")
      expect(response.body).to include("40")
    end
  end

  describe "#edit" do
    let(:client) { intake.client }
    let!(:form1099r) do
      create :state_file1099_r,
             payer_name: "Ace Hardware",
             recipient_name: "Phoenix Wright",
             payer_state_identification_number: 'az123456669',
             state_distribution_amount: 30,
             state_tax_withheld_amount: 40,
             intake: intake
    end
    let(:params) { { id: form1099r.id } }

    render_views

    context "when the intake's 1099R is editable" do
      it "renders information about the existing retirement income" do
        get :edit, params: params

        expect(response.body).to include("Ace Hardware")
        expect(response.body).to include("Phoenix Wright")
        expect(response.body).to include("az123456669")
        expect(response.body).to include("30")
        expect(response.body).to include("40")
      end

      context "when there are box 14 warnings" do
        context "state tax withheld more than gross distribution amount" do
          let!(:form1099r) { create :state_file1099_r, state_tax_withheld_amount: 40, gross_distribution_amount: 30, intake: intake }

          it "displays the errors on edit" do
            get :edit, params: params

            expect(response.body).to include I18n.t("activerecord.errors.models.state_file1099_r.errors.must_be_less_than_gross_distribution", gross_distribution_amount: 30)
          end
        end

        context "state tax withheld amount nil" do
          let!(:form1099r) { create :state_file1099_r, state_tax_withheld_amount: nil, intake: intake }

          it "displays the errors on edit" do
            get :edit, params: params

            expect(response.body).to include I18n.t("state_file.questions.retirement_income.edit.state_tax_withheld_absent_warning")
          end
        end

        context "state tax withheld amount is 0" do
          let!(:form1099r) { create :state_file1099_r, state_tax_withheld_amount: 0, intake: intake }

          it "displays the errors on edit" do
            get :edit, params: params

            expect(response.body).to include I18n.t("state_file.questions.retirement_income.edit.state_tax_withheld_absent_warning")
          end
        end
      end
    end
  end

  describe "#update" do
    let!(:form1099r) do
      create :state_file1099_r,
             state_distribution_amount: 15,
             payer_state_identification_number: 'NC3456767',
             state_tax_withheld_amount: 100,
             intake: intake
    end
    let(:params) do
      {
        id: form1099r.id,
        state_file1099_r: {
          state_distribution_amount: 20,
          payer_state_identification_number: 'Az3456789',
          state_tax_withheld_amount: 50
        }
      }
    end

    it "does not update the 1099R information and redirects to the income review page" do
      post :update, params: params

      expect(response).to redirect_to(questions_income_review_path)

      form1099r.reload
      expect(form1099r.state_distribution_amount).to eq 20
      expect(form1099r.payer_state_identification_number).to eq 'Az3456789'
      expect(form1099r.state_tax_withheld_amount).to eq 50
    end

    context "with invalid params" do
        render_views

        let(:params) do
          {
            id: form1099r.id,
            state_file1099_r: {
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

          expect(response.body).to include "must be greater than or equal to 0"
        end
      end

    context "when the intake's 1099R is not editable" do
      let(:intake) { create :state_file_nc_intake, :with_spouse }

      context "flipper flag is enabled" do
        before do
          allow(Flipper).to receive(:enabled?).and_call_original
          allow(Flipper).to receive(:enabled?).with(:nc_flip_flop).and_return(true)
        end

        it "updates the 1099R information and redirects to the income review page" do
          post :update, params: params

          expect(response).to redirect_to(questions_income_review_path)

          form1099r.reload
          expect(form1099r.state_distribution_amount).to eq 20
          expect(form1099r.payer_state_identification_number).to eq 'Az3456789'
          expect(form1099r.state_tax_withheld_amount).to eq 50
        end
      end

      context "flipper flag is disabled" do
        it "does not update the 1099R information" do
          post :update, params: params

          expect(response).to redirect_to(questions_income_review_path)

          form1099r.reload
          expect(form1099r.state_distribution_amount).to eq 15
          expect(form1099r.payer_state_identification_number).to eq 'NC3456767'
          expect(form1099r.state_tax_withheld_amount).to eq 100
        end
      end
    end
  end
end
