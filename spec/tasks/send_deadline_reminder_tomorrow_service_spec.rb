require 'rails_helper'

describe 'state_file:send_deadline_reminder_tomorrow' do
  let(:az_intake_1) { create :state_file_az_intake }
  let!(:az_intake_2) { create :state_file_az_intake }
  let(:md_intake) { create :state_file_md_intake }
  let(:nc_intake) { create :state_file_nc_intake }
  let(:id_intake) { create :state_file_id_intake }
  let(:nj_intake) { create :state_file_nj_intake }
  let!(:ny_intake) { create :state_file_ny_intake }

  before do
    Rake.application.rake_require "tasks/state_file"
    allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
    allow(StateFile::MessagingService).to receive(:new).and_return(spy('StateFile::MessagingService'))
    allow(StateFileAzIntake).to receive(:selected_intakes_for_deadline_reminder_soon_notifications).and_return([az_intake_1, md_intake, nc_intake, id_intake, nj_intake])
  end

  context "in 2025" do
    around do |example|
      # freezing the time to any time in 2025, since this task will only run in 2025
      Timecop.freeze(DateTime.parse("21-10-2025")) do
        example.run
      end
    end

    it 'sends to intakes with verified contact info, with or without df data, and without efile submissions or duplicate (same hashed_ssn) intakes with efile submission' do
      message = StateFile::AutomatedMessage::DeadlineReminderTomorrow
      service = StateFile::MessagingService

      Rake::Task['state_file:send_deadline_reminder_tomorrow'].execute
      expect(service).to have_received(:new).exactly(5).times

      expect(service).to have_received(:new).with(message: message, intake: az_intake_1)
      expect(service).to have_received(:new).with(message: message, intake: md_intake)
      expect(service).to have_received(:new).with(message: message, intake: nc_intake)
      expect(service).to have_received(:new).with(message: message, intake: id_intake)
      expect(service).to have_received(:new).with(message: message, intake: nj_intake)

      expect(service).not_to have_received(:new).with(message: message, intake: az_intake_2)
      expect(service).not_to have_received(:new).with(message: message, intake: ny_intake)
    end

    context "when environment is demo" do
      before do
        allow(Rails.env).to receive(:demo?).and_return true
      end

      it "doesn't run the task" do
        Rake::Task['state_file:send_deadline_reminder_tomorrow'].execute
        expect(StateFile::MessagingService).not_to have_received(:new)
      end
    end
  end

  context "when not in 2025" do
    around do |example|
      Timecop.freeze(DateTime.parse("21-10-2026")) do
        example.run
      end
    end

    it "doesn't run the task" do
      Rake::Task['state_file:send_deadline_reminder_tomorrow'].execute
      expect(StateFile::MessagingService).not_to have_received(:new)
    end
  end
end
