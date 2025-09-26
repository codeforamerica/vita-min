# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:send_deadline_reminder_today' do
  before(:all) do
    Rake.application.rake_require "tasks/state_file"
  end

  it 'sends messages via appropriate contact method to intakes without submissions, with or without df data that is not disqualifying' do
    az_intake_to_notify = create(:state_file_az_intake)
    az_intake_to_not_notify = create(:state_file_az_intake)
    nc_intake = create(:state_file_nc_intake)
    allow(StateFileAzIntake).to receive(:selected_intakes_for_deadline_reminder_soon_notifications).and_return([az_intake_to_notify])
    allow(StateFileNcIntake).to receive(:selected_intakes_for_deadline_reminder_soon_notifications).and_return([nc_intake])
    messaging_service = spy('StateFile::MessagingService')
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

    Rake::Task['state_file:send_deadline_reminder_today'].execute

    expect(StateFile::MessagingService).to have_received(:new).exactly(2).times
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::DeadlineReminderToday, intake: az_intake_to_notify)
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::DeadlineReminderToday, intake: nc_intake)
    expect(StateFile::MessagingService).to_not have_received(:new).with(message: StateFile::AutomatedMessage::DeadlineReminderToday, intake: az_intake_to_not_notify)
  end
end
