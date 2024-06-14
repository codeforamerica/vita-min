# frozen_string_literal: true
require 'rails_helper'

describe 'state_file:post_deadline_reminder' do
  before(:all) do
    Rake.application.rake_require "tasks/state_file"
  end

  context 'Sends the notification to all state-filing' do
    let!(:az_intake) { create :state_file_az_intake, email_address: 'test@example.com', email_address_verified_at: 1.minute.ago, created_at: 25.hours.ago }
    let!(:ny_intake) { create :state_file_ny_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago, created_at: 25.hours.ago }
    let!(:submitted_intake) { create :state_file_ny_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago }
    let!(:efile_submission) { create :efile_submission, :for_state, data_source: submitted_intake }

    it 'intakes without submissions & without reminders' do
      messaging_service = spy('StateFile::MessagingService')
      allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

      Rake::Task['state_file:post_deadline_reminder'].execute

      expect(StateFile::MessagingService).to have_received(:new).exactly(2).times
    end
  end

  context 'Sends the notification to intakes that have' do
    let!(:intake_with_reminder) {
      create :state_file_az_intake, email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago, created_at: 25.hours.ago
    }

    before do
      allow_any_instance_of(StateFileNyIntake).to receive(:message_tracker).and_return((Time.now - 25.hours).utc.to_s)
    end

    it 'the reminder_notification sent more than 24 hours ago' do
      messaging_service = spy('StateFile::MessagingService')
      allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

      Rake::Task['state_file:post_deadline_reminder'].execute

      expect(StateFile::MessagingService).to have_received(:new).exactly(1).times
    end
  end

  context 'Does NOT send the notification to' do
    let!(:intake_with_reminder) {
      create :state_file_az_intake, email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago, created_at: 25.hours.ago
    }

    before do
      allow_any_instance_of(StateFileAzIntake).to receive(:message_tracker).and_return(
        { "messages.state_file.finish_return" => (Time.now - 2.hours).utc.to_s }
      )
    end

    it 'intakes that have the reminder_notification sent less than 24 hours ago' do
      messaging_service = spy('StateFile::MessagingService')
      allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

      Rake::Task['state_file:post_deadline_reminder'].execute

      expect(StateFile::MessagingService).to have_received(:new).exactly(0).times
    end
  end
end
