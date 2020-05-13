require "rails_helper"

RSpec.describe Questions::AdditionalInfoController do
  render_views

  let(:intake) { create :intake, intake_ticket_id: 1234 }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:params) do
      { additional_info_form: { additional_info: "I moved here from Alaska." } }
    end

    it "enqueues a job to send the intake pdf to zendesk", active_job: true do
      post :update, params: params

      expect(SendIntakePdfToZendeskJob).to have_been_enqueued
    end
  end
end
