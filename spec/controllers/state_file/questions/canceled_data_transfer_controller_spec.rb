require "rails_helper"

RSpec.describe StateFile::Questions::CanceledDataTransferController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    context "when the client visits this page" do
      it "increments the counter" do
        state_file_analytics = intake.state_file_analytics
        state_file_analytics.update(canceled_data_transfer_count: 1)

        expect {
          get :edit, params: { us_state: 'az' }
          state_file_analytics.reload
        }.to change(state_file_analytics, :canceled_data_transfer_count)

        expect(state_file_analytics.canceled_data_transfer_count).to eq 2
      end
    end
  end
end
