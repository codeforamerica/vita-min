require 'rails_helper'

describe Ctc::Questions::Dependents::TinController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake, tin_type: nil, ssn: nil }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
          ctc_dependents_tin_form: {
            tin_type: "ssn",
            ssn: '555-11-2222',
            ssn_confirmation: '555-11-2222',
          }
        }
      end

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.ssn).to eq '555112222'
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_tin_form: {
            ssn: '555-11-2222',
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
        expect(assigns(:form).errors.keys).to include(:tin_type)
      end
    end
  end
end
