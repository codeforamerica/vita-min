# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:pre_deadline_reminder' do
  include_context "rake"

  before(:all) do
    Rake.application.rake_require "tasks/state_file"
  end

  around do |example|
    Timecop.freeze(DateTime.parse("2-12-2025")) do
      example.run
    end
  end

  let!(:az_intake_with_email_notifications_and_df_import) {
    create :state_file_az_intake,
           df_data_imported_at: 2.minutes.ago,
           email_address: 'test@example.com',
           email_address_verified_at: 5.minutes.ago,
           email_notification_opt_in: 1
  }
  let!(:az_intake_with_email_notifications_without_df_import) {
    create :state_file_az_intake,
           df_data_imported_at: nil,
           email_address: 'test@example.com',
           email_address_verified_at: 5.minutes.ago,
           email_notification_opt_in: 1
  }
  let!(:nc_intake_with_text_notifications_and_df_import) {
    create :state_file_az_intake,
           df_data_imported_at: 2.minutes.ago,
           phone_number: "+15551115511",
           sms_notification_opt_in: 1,
           phone_number_verified_at: 5.minutes.ago
  }
  let!(:nc_intake_with_unverified_text_notifications_and_df_import) {
    create :state_file_az_intake,
           df_data_imported_at: 2.minutes.ago,
           phone_number: "+15551115511",
           sms_notification_opt_in: 1
  }
  let!(:nc_intake_submitted) {
    create :state_file_nc_intake,
           df_data_imported_at: 2.minutes.ago,
           email_address: 'test+01@example.com',
           email_address_verified_at: 5.minutes.ago,
           email_notification_opt_in: 1
  }
  let!(:efile_submission) { create :efile_submission, :for_state, data_source: nc_intake_submitted }
  let!(:az_intake_has_received_reminder) {
    create :state_file_az_intake, email_address: "test@example.com",
           email_address_verified_at: 1.hour.ago,
           email_notification_opt_in: 1,
           df_data_imported_at: 2.minutes.ago,
           message_tracker: { "messages.state_file.finish_return" => (Time.now - 2.hours).utc.to_s }
  }
  let!(:md_intake_disqualifying_df_data) {
    create :state_file_md_intake,
           df_data_imported_at: 2.minutes.ago,
           email_address: 'test+01@example.com',
           email_address_verified_at: 5.minutes.ago,
           email_notification_opt_in: 1
  }

  it 'sends messages via appropriate contact method to intakes without submissions, with df data that is not disqualifying, who have not received a reminder in the last 24 hours' do
    allow_any_instance_of(StateFileMdIntake).to receive(:disqualifying_df_data_reason).and_return :has_out_of_state_w2

    messaging_service = instance_double(StateFile::MessagingService)
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)
    allow(messaging_service).to receive(:send_message)

    Rake::Task['state_file:pre_deadline_reminder'].execute

    expect(StateFile::MessagingService).to have_received(:new).exactly(3).times
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::PreDeadlineReminder, intake: az_intake_with_email_notifications_and_df_import)
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::PreDeadlineReminder, intake: nc_intake_with_text_notifications_and_df_import)
    expect(StateFile::MessagingService).to have_received(:new).with(message: StateFile::AutomatedMessage::PreDeadlineReminder, intake: nc_intake_with_unverified_text_notifications_and_df_import)
    expect(StateFile::MessagingService).not_to have_received(:new).with(message: StateFile::AutomatedMessage::PreDeadlineReminder, intake: az_intake_has_received_reminder)
    expect(StateFile::MessagingService).not_to have_received(:new).with(message: StateFile::AutomatedMessage::PreDeadlineReminder, intake: md_intake_disqualifying_df_data)
  end
end
