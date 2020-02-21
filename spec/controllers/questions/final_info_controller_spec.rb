require "rails_helper"

RSpec.describe Questions::FinalInfoController do
  render_views

  let(:intake) { create :intake }
  let(:user) { create :user, intake: intake }

  before do
    allow(subject).to receive(:current_user).and_return(user)
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
