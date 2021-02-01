require "rails_helper"

RSpec.describe Questions::AdditionalInfoController do
  let(:intake) { create :intake, completed_yes_no_questions_at: nil }

  describe "#update" do
    before do
      allow(subject).to receive(:current_intake).and_return(intake)
    end

    it "marks the completion of yes no questions and enqueues a job to create a preliminary 13614-C pdf", active_job: true do
      post :update, params: {}

      expect(intake.reload.completed_yes_no_questions_at).to be_present
      expect(IntakePdfJob).to have_been_enqueued.with(intake.id, "Preliminary 13614-C.pdf")
    end
  end
end

