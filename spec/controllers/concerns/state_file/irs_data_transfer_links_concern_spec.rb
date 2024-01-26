require "rails_helper"

RSpec.describe StateFile::IrsDataTransferLinksConcern, type: :controller do

  controller(ApplicationController) do
    include StateFile::IrsDataTransferLinksConcern
  end

  before do
    allow(subject).to receive(:return_url).and_return("http://localhost:3000/en/ny/questions/waiting-to-load-data")
  end

  describe "#fake_data_transfer_link" do
    context "when the environment is production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "returns false" do
        expect(subject.fake_data_transfer_link).to eq nil
      end
    end

    context "when the environment is staging" do
      before do
        allow(Rails).to receive(:env).and_return("staging".inquiry)
      end

      it "returns false" do
        expect(subject.fake_data_transfer_link).to eq nil
      end
    end

    context "when the environment is in development" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it "returns the fake direct file transfer page link" do
        expect(subject.fake_data_transfer_link.query).to include "waiting-to-load-data"
        expect(subject.fake_data_transfer_link.path).to include "fake_direct_file_transfer_page"
      end
    end

    context "when the environment is in demo" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
        allow(subject).to receive(:return_url).and_return("https://demo.fileyourstatetaxes.org/en/ny/questions/waiting-to-load-data")
      end

      it "returns the fake direct file transfer page link" do
        expect(subject.fake_data_transfer_link.query).to include "waiting-to-load-data"
        expect(subject.fake_data_transfer_link.path).to include "fake_direct_file_transfer_page"
      end
    end
  end

  describe "#irs_df_transfer_link" do
    before do
      allow(EnvironmentCredentials).to receive(:dig).with("statefile", "df_transfer_auth").and_return "https://example.df.gov/auth-state"
    end

    it "returns link" do
      expect(subject.irs_df_transfer_link.query).to include "waiting-to-load-data"
      expect(subject.irs_df_transfer_link.path).to include "/auth-state"
    end
  end
end
