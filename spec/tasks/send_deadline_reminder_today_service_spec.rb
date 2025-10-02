# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:send_deadline_reminder_today' do
  before do
    Rake.application.rake_require "tasks/state_file"
    allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
    messaging_service = spy('StateFile::MessagingService')
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)
    allow(StateFileAzIntake).to receive(:selected_intakes_for_deadline_reminder_soon_notifications).and_return([az_intake_1, md_intake, nc_intake, id_intake, nj_intake])
  end

  around do |example|
    # freezing the time to any time in 2025, since this task will only run in 2025
    Timecop.freeze(DateTime.parse("2-12-2025")) do
      example.run
    end
  end

  let(:az_intake_1) { create :state_file_az_intake }
  let!(:az_intake_2) { create :state_file_az_intake }
  let(:md_intake) { create :state_file_md_intake }
  let(:nc_intake) { create :state_file_nc_intake }
  let(:id_intake) { create :state_file_id_intake }
  let(:nj_intake) { create :state_file_nj_intake }
  let!(:ny_intake) { create :state_file_ny_intake }

  it 'sends to intakes with verified contact info, with or without df data, and without efile submissions or duplicate (same hashed_ssn) intakes with efile submission' do
    message = StateFile::AutomatedMessage::DeadlineReminderToday
    service = StateFile::MessagingService

    Rake::Task['state_file:send_deadline_reminder_today'].execute
    expect(service).to have_received(:new).exactly(5).times

    expect(service).to have_received(:new).with(message: message, intake: az_intake_1)
    expect(service).to have_received(:new).with(message: message, intake: md_intake)
    expect(service).to have_received(:new).with(message: message, intake: nc_intake)
    expect(service).to have_received(:new).with(message: message, intake: id_intake)
    expect(service).to have_received(:new).with(message: message, intake: nj_intake)

    expect(service).not_to have_received(:new).with(message: message, intake: az_intake_2)
    expect(service).not_to have_received(:new).with(message: message, intake: ny_intake)
  end
end
