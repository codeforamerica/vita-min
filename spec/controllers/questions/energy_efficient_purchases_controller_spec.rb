require "rails_helper"

RSpec.describe Questions::EnergyEfficientPurchasesController do
  let(:intake) { create :intake, completed_yes_no_questions_at: nil }

  describe "#update" do
    before { sign_in intake.client }

    context "with valid params" do
      let(:params) do
        {
          energy_efficient_purchases_form: {
            bought_energy_efficient_items: "yes"
          }
        }
      end

      it "marks the completion of yes no questions and enqueues a job to create a preliminary 13614-C pdf", active_job: true do
        post :update, params: params

        expect(intake.reload.bought_energy_efficient_items).to eq("yes")
        expect(intake.reload.completed_yes_no_questions_at).to be_present
        expect(GenerateF13614cPdfJob).to have_been_enqueued.with(intake.id, "Preliminary 13614-C.pdf")
      end
    end
  end
end

