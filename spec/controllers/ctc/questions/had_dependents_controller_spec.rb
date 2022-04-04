require "rails_helper"

RSpec.describe Ctc::Questions::HadDependentsController do
  let(:had_dependents) { "unfilled" }
  let(:intake) { create :ctc_intake, had_dependents: had_dependents }
  before { sign_in intake.client }

  describe "#next_path" do
    context "when the client has already added some dependents" do
      let(:intake) { create :ctc_intake, :with_dependents, had_dependents: had_dependents }

      context "when the client answers yes" do
        it "returns the confirm dependents page" do
          put :update, params: { ctc_had_dependents_form: { had_dependents: "yes" } }

          expect(response).to redirect_to questions_confirm_dependents_path
        end
      end

      context "when the client answers no" do
        it "returns the confirm dependents page" do
          put :update, params: { ctc_had_dependents_form: { had_dependents: "no" } }

          expect(response).to redirect_to questions_confirm_dependents_path
        end
      end
    end

    context "when the client has not added any dependents yet" do

      context "when the client answers yes" do
        let(:info_controller_path) { double }

        before do
          allow_any_instance_of(Intake).to receive(:new_dependent_token).and_return("new")
        end

        it "returns the dependents path" do
          put :update, params: { ctc_had_dependents_form: { had_dependents: "yes" } }

          expect(response).to redirect_to Ctc::Questions::Dependents::InfoController.to_path_helper(id: "new")
        end
      end

      context "when the client answers no" do
        let(:had_dependents) { "no" }

        it "returns the default next navigation path" do
          put :update, params: { ctc_had_dependents_form: { had_dependents: "no" } }

          expect(response).to redirect_to questions_stimulus_payments_path
        end
      end
    end
  end
end

