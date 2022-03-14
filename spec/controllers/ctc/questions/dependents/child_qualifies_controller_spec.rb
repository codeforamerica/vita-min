require 'rails_helper'

describe Ctc::Questions::Dependents::ChildQualifiesController do
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
          ctc_dependents_child_qualifies_form: {
            full_time_student: "yes",
            permanently_totally_disabled: "yes"
          }
        }
      end

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.full_time_student).to eq "yes"
        expect(dependent.reload.permanently_totally_disabled).to eq "yes"
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'invalid_id',
          ctc_dependents_child_disqualifiers_form: {
            full_time_student: "yes",
            permanently_totally_disabled: "yes"
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
