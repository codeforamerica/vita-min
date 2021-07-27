require 'rails_helper'

describe Ctc::Questions::Dependents::RemoveDependentController do
  let(:intake) { create :ctc_intake }
  let!(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
        }
      end

      it "destroys the dependent" do
        expect {
          post :update, params: params
        }.to change(intake.dependents, :count).by -1
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_remove_dependent_form: {
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
