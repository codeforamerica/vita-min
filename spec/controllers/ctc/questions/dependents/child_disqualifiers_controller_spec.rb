require 'rails_helper'

describe Ctc::Questions::Dependents::ChildDisqualifiersController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
          ctc_dependents_child_disqualifiers_form: {
            provided_over_half_own_support: "yes",
            filed_joint_return: "yes"
          }
        }
      end

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.provided_over_half_own_support).to eq "yes"
        expect(dependent.reload.provided_over_half_own_support).to eq "yes"
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_child_disqualifiers_form: {
            provided_over_half_own_support: "yes",
            filed_joint_return: "yes"
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
        expect(assigns(:form).errors.keys).to include(:none_selected)
      end
    end
  end
end
