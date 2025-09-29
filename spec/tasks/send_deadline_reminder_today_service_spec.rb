# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:send_deadline_reminder_today' do
  before do
    Rake.application.rake_require "tasks/state_file"
    allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
    messaging_service = spy('StateFile::MessagingService')
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)
    allow(StateFileAzIntake).to receive(:selected_intakes_for_deadline_reminder_soon_notifications).and_return([az_intake_1, az_intake_2, az_intake_3])
  end

  around do |example|
    # freezing the time to any time in 2025, since this task will only run in 2025
    Timecop.freeze(DateTime.parse("2-12-2025")) do
      example.run
    end
  end

  let!(:az_intake_1) { create :state_file_az_intake, email_address: 'test_1@example.com', email_address_verified_at: 5.minutes.ago, email_notification_opt_in: 1 }
  let!(:az_intake_2) { create :state_file_az_intake, email_address: 'test_4@example.com', phone_number: "+15551115511", sms_notification_opt_in: 1, phone_number_verified_at: 5.minutes.ago }
  let!(:az_intake_3) { create :state_file_az_intake, phone_number: "+15551115511", sms_notification_opt_in: "yes", email_address: 'test_5@example.com', email_address_verified_at: 5.minutes.ago, email_notification_opt_in: "no" }

  it 'sends to intakes with verified contact info, with or without df data, and without efile submissions or duplicate (same hashed_ssn) intakes with efile submission' do
    Rake::Task['state_file:send_deadline_reminder_today'].execute
    expect(StateFile::MessagingService).to have_received(:new).exactly(3).times
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::DeadlineReminderToday, intake: az_intake_1)
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::DeadlineReminderToday, intake: az_intake_2)
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::DeadlineReminderToday, intake: az_intake_3)
  end
end
