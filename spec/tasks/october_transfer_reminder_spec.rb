require 'rails_helper'

describe 'state_file:october_transfer_reminder' do
  let(:messaging_service) { spy('StateFile::MessagingService') }
  let!(:az_intake_to_notify) { create(:state_file_az_intake) }
  let!(:az_intake_to_not_notify) { create(:state_file_az_intake) }
  let!(:nc_intake) { create(:state_file_nc_intake) }

  before do
    Rake.application.rake_require "tasks/state_file"
    allow(StateFileAzIntake).to receive(:selected_intakes_for_first_deadline_reminder_notification).and_return([az_intake_to_notify])
    allow(StateFileNcIntake).to receive(:selected_intakes_for_first_deadline_reminder_notification).and_return([nc_intake])
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)
  end

  context "in 2025" do
    around do |example|
      Timecop.freeze(DateTime.parse("16-10-2025")) do
        example.run
      end
    end

    it 'sends messages via appropriate contact method to intakes without submissions, with or without df data that is not disqualifying' do
      Rake::Task['state_file:send_october_transfer_reminder'].execute

      expect(StateFile::MessagingService).to have_received(:new).exactly(2).times
      expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: az_intake_to_notify)
      expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: nc_intake)
      expect(StateFile::MessagingService).to_not have_received(:new).with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: az_intake_to_not_notify)
    end

    context "when environment is demo" do
      before do
        allow(Rails.env).to receive(:demo?).and_return true
      end

      it "doesn't run the task" do
        Rake::Task['state_file:send_october_transfer_reminder'].execute
        expect(StateFile::MessagingService).not_to have_received(:new)
      end
    end
  end

  context "when not in 2025" do
    around do |example|
      Timecop.freeze(DateTime.parse("16-10-2026")) do
        example.run
      end
    end

    it "doesn't run the task" do
      Rake::Task['state_file:send_october_transfer_reminder'].execute
      expect(StateFile::MessagingService).not_to have_received(:new)
    end
  end
end