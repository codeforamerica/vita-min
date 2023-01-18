require 'rails_helper'

describe 'client_surveys:send_completion_surveys' do
  include_context "rake"

  around do |example|
    capture_output { example.run }
  end

  describe "AutomatedMessage::CtcExperienceSurvey" do
    let!(:client) do
      Timecop.freeze(25.hours.ago) do
        create :ctc_tax_return, status, client: build(:client, ctc_experience_survey_sent_at: nil, intake: build(:ctc_intake, primary_consented_to_service: "yes"))
      end.client
    end
    let(:status) { :file_accepted }

    it "enqueues surveys" do
      expect {
        task.invoke
      }.to have_enqueued_job(SendClientCtcExperienceSurveyJob).with(client)
    end
  end

  describe "AutomatedMessage::CompletionSurvey" do
    let(:completion_survey_sent_at) { nil }
    let!(:client) do
      Timecop.freeze(25.hours.ago) do
        create :gyr_tax_return, status, client: build(:client, completion_survey_sent_at: completion_survey_sent_at, intake: build(:intake, primary_consented_to_service: "yes"))
      end.client
    end
    let(:status) { :file_accepted }

    it "enqueues surveys" do
      expect {
        task.invoke
      }.to have_enqueued_job(SendClientCompletionSurveyJob).with(client)
    end
  end
end


