require "rails_helper"

describe Ctc::Questions::Dependents::RelativeQualifiersController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :qualifying_relative, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:cant_be_claimed_by_other) { "yes" }
      let(:below_qualifying_relative_income_requirement) { "yes" }
      let(:params) do
        {
            id: dependent.id,
            ctc_dependents_relative_qualifiers_form: {
                cant_be_claimed_by_other: cant_be_claimed_by_other,
                below_qualifying_relative_income_requirement: below_qualifying_relative_income_requirement,
                none_of_the_above: "no"
            }
        }
      end
      context "when both answers are yes" do
        let(:cant_be_claimed_by_other) { "yes" }
        let(:below_qualifying_relative_income_requirement) { "yes" }
        it "updates the dependent and moves to the confirmation page" do
          post :update, params: params

          expect(dependent.reload.cant_be_claimed_by_other).to eq "yes"
          expect(dependent.reload.below_qualifying_relative_income_requirement).to eq "yes"
          expect(response).to redirect_to questions_confirm_dependents_path
        end
      end
      
      context "when income requirement is no" do
        let(:cant_be_claimed_by_other) { "yes" }
        let(:below_qualifying_relative_income_requirement) { "no" }

        it "offboards client to not eligible page" do
          post :update, params: params

          expect(dependent.reload.cant_be_claimed_by_other).to eq "yes"
          expect(dependent.reload.below_qualifying_relative_income_requirement).to eq "no"
          expect(response).to redirect_to does_not_qualify_ctc_questions_dependent_path(id: params[:id])
        end
      end
      
      context "when claimable is no" do
        let(:cant_be_claimed_by_other) { "no" }
        let(:below_qualifying_relative_income_requirement) { "yes" }

        it "offboards client to not eligible page" do
          post :update, params: params

          expect(dependent.reload.cant_be_claimed_by_other).to eq "no"
          expect(dependent.reload.below_qualifying_relative_income_requirement).to eq "yes"
          expect(response).to redirect_to does_not_qualify_ctc_questions_dependent_path(id: params[:id])
        end
      end
      
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
            id: 'invalid_id',
            ctc_dependents_relative_qualifiers_form: {
              cant_be_claimed_by_other: "yes",
              below_qualifying_relative_income_requirement: "yes",
              none_of_the_above: "no"
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
        expect(assigns(:form).errors.attribute_names).to include(:none_of_the_above)
      end
    end
  end
end