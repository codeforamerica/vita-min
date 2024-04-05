require 'rails_helper'

RSpec.describe StateFile::Questions::InitiateDataTransferController do
  let(:intake) { create :state_file_ny_intake }
  let(:state_file_analytics) { intake.state_file_analytics }
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

    context "it has a link to initiate_data_transfer when irs_df_transfer_link returns a link" do
      render_views

      it "has a link to the initiate_data_transfer action (which redirects to the right data transfer link)" do
        df_link = "https://fake-df-transfer.gov"
        allow(subject).to receive(:irs_df_transfer_link).and_return(df_link)
        get :edit, params: { us_state: 'ny' }

        expect(response.body).to have_link(href: described_class.to_path_helper(action: :initiate_data_transfer, us_state: 'ny'))
      end
    end
  end

  describe "#initiate_data_transfer" do
    it "increments the count of clicks on data transfer and redirects to direct file" do
      df_link = URI.parse("https://fake-df-transfer.gov")
      allow(subject).to receive(:irs_df_transfer_link).and_return(df_link)
      allow(subject).to receive(:redirect_to)
      get :initiate_data_transfer, params: { us_state: 'ny' }

      expect(state_file_analytics.reload.initiate_df_data_transfer_clicks).to eq 1
      expect(subject).to have_received(:redirect_to).with(df_link.to_s, allow_other_host: true)
    end
  end
end