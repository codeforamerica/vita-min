require 'rails_helper'

describe Ctc::Questions::Dependents::ChildClaimAnywayController do
  let(:intake) { create :ctc_intake, client: create(:client, :with_return) }
  let(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
          ctc_dependents_child_claim_anyway_form: {
            claim_anyway: claim_anyway
          }
        }
      end

      let(:claim_anyway) { "yes" }

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.claim_anyway).to eq "yes"
      end

      context "with a no answer" do
        let(:claim_anyway) { "no" }

        it "redirects out of the dependent flow" do
          post :update, params: params

          expect(dependent.reload.claim_anyway).to eq "no"
          expect(response).to redirect_to Ctc::Questions::Dependents::DoesNotQualifyCtcController.to_path_helper
        end
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_child_claim_anyway_form: {
            claim_anyway: "yes"
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
        expect(assigns(:form).errors.attribute_names).to include(:claim_anyway)
      end
    end
  end
end
