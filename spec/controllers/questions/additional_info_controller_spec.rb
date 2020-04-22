require "rails_helper"

RSpec.describe Questions::AdditionalInfoController do
  render_views

  let(:intake) { create :intake }
  let(:user) { create :user, intake: intake }

  before do
    allow(subject).to receive(:current_user).and_return(user)
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
