require 'rails_helper'

describe 'client_surveys:send_client_in_progress_surveys' do
  include_context "rake"

  around do |example|
    capture_output { example.run }
  end

  context "with a client to survey" do
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }
    let!(:client) do
      Timecop.freeze(fake_time - 20.days) do
        create :tax_return, :intake_in_progress, client: create(:client, in_progress_survey_sent_at: nil, intake: create(:intake, primary_consented_to_service: "yes"))
      end.client
    end

    it "sends an email to them" do
      expect {
        task.invoke
      }.to have_enqueued_job(SendClientInProgressSurveyJob).with(client)
    end
  end
end
