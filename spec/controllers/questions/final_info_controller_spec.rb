require "rails_helper"

RSpec.describe Questions::FinalInfoController do
  render_views

  let(:intake) { create :intake, intake_ticket_id: 1234 }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:params) do
      { final_info_form: { final_info: "I moved here from Alaska." } }
    end

    it "enqueues a job to update the zendesk ticket", active_job: true do
      post :update, params: params

      expect(SendCompletedIntakeToZendeskJob).to have_been_enqueued
    end
  end
end
