require 'rails_helper'

describe 'send_survey_notifications rake task' do
  let!(:intake) { create :state_file_az_intake, email_address: "test@example.com", email_address_verified_at: 1.minute.ago }
  let!(:efile_submission) { create :efile_submission, :for_state, :accepted, data_source: intake }
  let!(:ctc_efile_submission) { create :efile_submission, :accepted}
  before(:all) do
    Rails.application.load_tasks
  end
  it 'runs without error for all state-filing submissions' do
    Rake::Task['survey_notifications:send'].execute
  end
end
