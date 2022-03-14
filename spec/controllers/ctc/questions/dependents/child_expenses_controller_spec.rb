require 'rails_helper'

describe Ctc::Questions::Dependents::ChildExpensesController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:answer) { "yes" }

      let(:params) do
        {
            id: dependent.id,
            ctc_dependents_child_expenses_form: {
                provided_over_half_own_support: answer,
            }
        }
      end

      context "when yes" do
        let(:answer) { "yes" }

        it "updates the dependent and offboards them" do
          post :update, params: params

          expect(dependent.reload.provided_over_half_own_support).to eq "yes"
          expect(response).to redirect_to does_not_qualify_ctc_questions_dependent_path(id: dependent.id)
        end
      end

      context "when no" do
        let(:answer) { "no" }
        it "updates the dependent and goes to next dependent question" do
          post :update, params: params

          expect(dependent.reload.provided_over_half_own_support).to eq "no"
          expect(response).to redirect_to child_lived_with_you_questions_dependent_path(id: dependent.id)
        end
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
            id: 'jeff',
            ctc_dependents_child_expenses_form: {
                provided_over_half_own_support: "yes",
            }
        }
      end

      it "renders 404" do
        expect do
          post :update, params: params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end