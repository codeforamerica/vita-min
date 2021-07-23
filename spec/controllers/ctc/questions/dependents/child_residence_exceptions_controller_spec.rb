require 'rails_helper'

describe Ctc::Questions::Dependents::ChildResidenceExceptionsController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake, lived_with_less_than_six_months: "yes" }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
          ctc_dependents_child_residence_exceptions_form: {
            born_in_2020: "yes",
            passed_away_2020: "no",
            placed_for_adoption: "yes",
            permanent_residence_with_client: "no"
          }
        }
      end

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.born_in_2020).to eq 'yes'
        expect(dependent.reload.passed_away_2020).to eq 'no'
        expect(dependent.reload.placed_for_adoption).to eq 'yes'
        expect(dependent.reload.permanent_residence_with_client).to eq 'no'
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_child_residence_exceptions_form: {
            born_in_2020: "yes",
            passed_away_2020: "no",
            placed_for_adoption: "yes",
            permanent_residence_with_client: "no"
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
