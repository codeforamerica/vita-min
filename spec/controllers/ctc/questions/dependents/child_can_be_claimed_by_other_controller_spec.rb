require 'rails_helper'

describe Ctc::Questions::Dependents::ChildCanBeClaimedByOtherController do
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
          ctc_dependents_child_can_be_claimed_by_other_form: {
            cant_be_claimed_by_other: "no"
          }
        }
      end

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.cant_be_claimed_by_other).to eq "no"
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_child_can_be_claimed_by_other_form: {
            cant_be_claimed_by_other: "no"
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
        expect(assigns(:form).errors.attribute_names).to include(:cant_be_claimed_by_other)
      end
    end
  end
end
