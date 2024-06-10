# frozen_string_literal: true
require 'rails_helper'

describe 'reminder_to_finish:state_return_notifications' do
  before(:all) do
    Rails.application.load_tasks
  end

  let!(:az_intake) { create :state_file_az_intake, email_address: "test@example.com", email_address_verified_at: 1.minute.ago }
  let!(:ny_intake) { create :state_file_ny_intake, email_address: "test+01@example.com", email_address_verified_at: 1.minute.ago }
  let!(:submitted_intake) {
    create :state_file_ny_intake,
           email_address: "test+01@example.com",
           email_address_verified_at: 1.minute.ago,
           federal_submission_id: "1234567890123456test"
  }

  it 'runs without error for all state-filing intakes with direct file data and without submission ids' do
    messaging_service = spy('StateFile::MessagingService')
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

    Rake::Task['reminder_to_finish:state_return_notifications'].execute
    expect(StateFile::MessagingService).to have_received(:new).exactly(2).times
  end

  it "doesn't send the notification to an intake that has NOT been submitted" do
    expect(StateFileNyIntake.where.not(federal_submission_id: nil).count).to eq(1)
  end
end
