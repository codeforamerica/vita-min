require 'rails_helper'

describe StateFile::ReminderToFinishStateReturnService do

  describe ".run" do
    let(:message) { StateFile::AutomatedMessage::FinishReturn }
    let(:state_file_messaging_service) { StateFile::MessagingService.new(intake: intake, message: message) }

    before do
      allow(StateFile::MessagingService).to receive(:new).with(intake: intake, message: message).and_return(state_file_messaging_service)
      allow(state_file_messaging_service).to receive(:send_message)
    end

    context 'when there is a started intake from more than 12 hours ago' do
      let!(:intake) { create :state_file_az_intake, created_at: (12.hours + 1.minute).ago, email_address: 'rkreyhsig@codeforamerica.org' }

      it 'sends a message to the email associated with the intake' do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, message: message)
        expect(state_file_messaging_service).to have_received(:send_message)
      end
    end

    context 'when there is a started intake from less than 12 hours ago' do
      let(:intake) { create :state_file_az_intake, created_at: (11.hours + 59.minutes).ago, email_address: 'rkreyhsig@codeforamerica.org' }
      it 'does not send a message to the email associated with the intake' do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end
  end
end
