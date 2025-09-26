# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:send_deadline_reminder_today' do
  before do
    Rake.application.rake_require "tasks/state_file"
    allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
    messaging_service = spy('StateFile::MessagingService')
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)
  end

  context "for AZ intakes" do
    let!(:az_intake_with_email_notifications_and_df_import) {
      create :state_file_az_intake,
             email_address: 'test_1@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    } #X
    let!(:az_intake_with_email_notifications_and_df_import_from_last_year) {
      create :state_file_az_intake,
             email_address: 'test_2@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1,
             created_at: (1.year.ago)
    }
    let!(:az_intake_with_email_notifications_without_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: nil,
             email_address: 'test_3@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    } #X
    let!(:az_intake_with_sms_and_df_import) {
      create :state_file_az_intake,
             email_address: 'test_4@example.com',
             phone_number: "+15551115511",
             sms_notification_opt_in: 1,
             phone_number_verified_at: 5.minutes.ago
    } #X
    let!(:az_intake_with_unverified_sms_verified_email) {
      create :state_file_az_intake,
             phone_number: "+15551115511",
             sms_notification_opt_in: "yes",
             email_address: 'test_5@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: "no"
    } #X
    let!(:az_intake_submitted) {
      create :state_file_az_intake,
             email_address: 'test_6@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:efile_submission) { create :efile_submission, :for_state, data_source: az_intake_submitted }
    let!(:az_intake_has_disqualifying_df_data) {
      create :state_file_az_intake,
             filing_status: :married_filing_separately,
             email_address: "test_7@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1
    }
    let!(:az_intake_with_no_raw_direct_file_data) {
      create :state_file_az_intake,
             raw_direct_file_data: nil,
             raw_direct_file_intake_data: nil,
             email_address: 'test_9@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    } #X
    let!(:az_intake_submitted_ssn_dupe_with_submission) {
      create :state_file_az_intake,
             email_address: "test_8@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             phone_number: nil,
             hashed_ssn: "111443333"
    }
    let!(:efile_submission_for_duplicate) {
      create :efile_submission,
             :for_state,
             data_source: az_intake_submitted_ssn_dupe_with_submission
    }
    let!(:az_intake_submitted_ssn_match_for_dupe) {
      create :state_file_az_intake,
             email_address: "test_8@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             phone_number: nil,
             hashed_ssn: "111443333"
    }


    it 'sends to intakes with verified_contact info' do
      Rake::Task['state_file:send_deadline_reminder_today'].execute
      expect(StateFile::MessagingService).to have_received(:new).exactly(5).times
      expect(StateFile::MessagingService).to have_received(:new).with(
        message: StateFile::AutomatedMessage::DeadlineReminderToday,
        intake: az_intake_with_email_notifications_and_df_import
      )
      expect(StateFile::MessagingService).to have_received(:new).with(
        message: StateFile::AutomatedMessage::DeadlineReminderToday,
        intake: az_intake_with_email_notifications_without_df_import
      )
      expect(StateFile::MessagingService).to have_received(:new).with(
        message: StateFile::AutomatedMessage::DeadlineReminderToday,
        intake: az_intake_with_sms_and_df_import
      )
      expect(StateFile::MessagingService).to have_received(:new).with(
        message: StateFile::AutomatedMessage::DeadlineReminderToday,
        intake: az_intake_with_unverified_sms_verified_email
      )
      expect(StateFile::MessagingService).to have_received(:new).with(
        message: StateFile::AutomatedMessage::DeadlineReminderToday,
        intake: az_intake_with_no_raw_direct_file_data
      )
    end

  end
end
