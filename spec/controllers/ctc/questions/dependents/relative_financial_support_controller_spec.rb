require "rails_helper"

describe Ctc::Questions::Dependents::RelativeFinancialSupportController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :qualifying_relative, intake: intake, relationship: "other", residence_lived_with_all_year: "yes" }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:answer) { "yes" }
      let(:params) do
        {
            id: dependent.id,
            ctc_dependents_relative_financial_support_form: {
                filer_provided_over_half_support: answer
            }
        }
      end

      context "when yes" do
        let(:answer) { "yes" }

        it "updates the dependent and moves to the next page" do
          post :update, params: params

          expect(dependent.reload.filer_provided_over_half_support).to eq "yes"
          expect(response).to redirect_to relative_qualifiers_questions_dependent_path(id: params[:id])
        end
      end

      context "when no" do
        let(:answer) { "no" }

        it "updates the dependent, disqualifies them, and offboards them" do
          post :update, params: params

          expect(dependent.reload.filer_provided_over_half_support).to eq "no"
          expect(response).to redirect_to does_not_qualify_ctc_questions_dependent_path(id: params[:id])
        end
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
            id: 'jeff',
            ctc_relative_financial_support_form: {
                filer_provided_over_half_support: "yes"
            }
        }
      end

      it "renders 404" do
        expect do
          post :update, params: params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with invalid params" do
      let(:params) do
        {
            id: dependent.id
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors.attribute_names).to include(:filer_provided_over_half_support)
      end
    end
  end
end