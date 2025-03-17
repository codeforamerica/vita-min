require 'rails_helper'

RSpec.describe StateFileSubmissionPdfStatusChannel, type: :channel do
  let(:intake) { create(:state_file_az_intake) }

  before do
    stub_connection current_state_file_intake: intake
  end

  context "before the bundle submission PDF job runs" do
    it "broadcasts processing when the submission PDF is not attached" do
      subscribe

      expect {
        perform(:status_update)
      }.to have_broadcasted_to(intake).with(status: :processing)
    end
  end
end
