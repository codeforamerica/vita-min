require 'rails_helper'

RSpec.describe StateFile::Questions::InitiateDataTransferController do
  let(:intake) { create :state_file_ny_intake }
  let!(:state_file_analytics) { StateFileAnalytics.create(record: intake) }
  before do
    sign_in intake
  end

  describe "#edit" do
    context "when it is the client's first visit to this page" do
      it "saves the timestamp for the first visit" do
        expect {
          get :edit, params: { us_state: 'ny' }
          state_file_analytics.reload
        }.to change(state_file_analytics, :initiate_data_transfer_first_visit_at)

        expect(state_file_analytics.initiate_data_transfer_first_visit_at).to be_within(1.second).of(DateTime.now)
      end
    end

    context "when it is not the client's first visit to the page" do
      it "does nothing" do
        state_file_analytics.update(initiate_data_transfer_first_visit_at: 1.day.ago)
        expect {
          get :edit, params: { us_state: 'ny' }
          state_file_analytics.reload
        }.not_to change(state_file_analytics, :initiate_data_transfer_first_visit_at)
      end
    end
  end

  describe "#data_transfer" do
    it "increments the count of clicks on data transfer and redirects to direct file" do
      df_link = "https://google.com"
      allow(subject).to receive(:irs_df_transfer_link).and_return(df_link)
      get :data_transfer, params: { us_state: 'ny' }

      expect(state_file_analytics.reload.initiate_df_data_transfer_clicks).to eq 1
      expect(response).to redirect_to df_link

      # breaking with "Expected response to be a <3XX: redirect>, but was a <400: Bad Request>"
      # Next steps: why is the request bad? why not a redirect
      # Also need to need to add a test for the view if it isn't covered by the feature specs
    end
  end
end