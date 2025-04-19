# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:post_deadline_reminder' do
  before(:all) do
    Rake.application.rake_require "tasks/state_file"
  end

  around do |example|
    Timecop.freeze(DateTime.parse("2-12-2025")) do
      example.run
    end
  end

  it 'sends messages via appropriate contact method to intakes without submissions, with df data that is not disqualifying, who have not received a reminder in the last 24 hours' do
    az_intake = create(:state_file_az_intake)
    nc_intake = create(:state_file_nc_intake)
    allow(StateFileAzIntake).to receive(:selected_intakes_for_deadline_reminder_notifications).and_return([az_intake])
    allow(StateFileNcIntake).to receive(:selected_intakes_for_deadline_reminder_notifications).and_return([nc_intake])
    messaging_service = spy('StateFile::MessagingService')
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

    Rake::Task['state_file:post_deadline_reminder'].execute

    expect(StateFile::MessagingService).to have_received(:new).exactly(2).times
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::PostDeadlineReminder, intake: az_intake)
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::PostDeadlineReminder, intake: nc_intake)
  end
end
