require 'rails_helper'

RSpec.describe StateFile::Questions::AzSeniorDependentsController do

  let(:dependent_name) { :az_senior_dependent }
  let(:dependent) { create(dependent_name) }
  let(:intake) { create(:state_file_az_intake, dependents: [dependent]) }
  before { sign_in intake }

  describe ".show?" do
    context "with any senior dependents" do
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "without senior dependents" do
      let(:dependent_name) { :state_file_dependent }
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "with the return to review parameter" do
      it "returns to review" do
        params = {
          state_file_az_senior_dependents_form: {
            dependents_attributes: {
              "0": {
                id: dependent.id,
                needed_assistance: "yes",
                passed_away: "no"
              }
            }
          },
          return_to_review: :y,
          us_state: :az
        }
        post :update, params: params
        expect(response).to redirect_to "/en/az/questions/az-review"
      end
    end
  end
end
