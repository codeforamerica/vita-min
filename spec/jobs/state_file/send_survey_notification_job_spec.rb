require 'rails_helper'

RSpec.describe StateFile::SendSurveyNotificationJob, type: :job do
  describe '#perform' do
    let(:intake) { create :state_file_az_intake }
    let(:submission) { create :efile_submission, :for_state, data_source: intake }
    let(:message) { StateFile::AutomatedMessage::SurveyNotification }
    let(:body_args) {
      {
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey"
      }
    }
    let(:state_file_messaging_service) { instance_double(StateFile::MessagingService) }

    it "sends the notification" do
      allow(StateFile::MessagingService).to receive(:new).and_return(state_file_messaging_service)
      allow(state_file_messaging_service).to receive(:send_message)

      described_class.perform_now(intake, submission)

      expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: submission, message: message, body_args: body_args)
      expect(state_file_messaging_service).to have_received(:send_message)
    end
  end
end

