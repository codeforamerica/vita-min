require 'rails_helper'

describe StillNeedsHelpService do
  describe "#must_show_still_needs_help_flow?" do
    context "with a client who has triggered still needs help" do
      let(:client) { create(:client, triggered_still_needs_help_at: Time.now) }

      it "returns true" do
        expect(described_class.must_show_still_needs_help_flow?(client)).to eq(true)
      end
    end

    context "with a client who has not triggered still needs help" do
      let(:client) { create(:client, triggered_still_needs_help_at: nil) }

      it "returns false" do
        expect(described_class.must_show_still_needs_help_flow?(client)).to eq(false)
      end
    end
  end

  describe "#trigger_still_needs_help_flow" do
    let(:tax_returns) { [] }
    let(:client) { create(:client, tax_returns: tax_returns) }
    let!(:intake) { create(:intake, client: client) }
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

    it "sets the client's triggered_still_needs_help_at timestamp" do
      expect do
        Timecop.freeze(fake_time) { described_class.trigger_still_needs_help_flow(client) }
      end.to change(client, :triggered_still_needs_help_at).from(nil).to(fake_time)
    end

    context "with tax returns with status ready for review (aka intake ready)" do
      let(:tax_returns) { [
        build(:tax_return, status: :intake_ready, year: 2019),
        build(:tax_return, status: :intake_ready, year: 2018)
      ] }

      it "marks them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:status).uniq).to eq(["file_not_filing"])
      end
    end

    context "with tax returns with status not ready (aka in progress)" do
      let(:tax_returns) { [
        build(:tax_return, status: :intake_in_progress, year: 2019),
        build(:tax_return, status: :intake_in_progress, year: 2018)
      ] }

      it "marks them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:status).uniq).to eq(["file_not_filing"])
      end
    end

    context "with returns in other statuses" do
      let(:tax_returns) { [
        build(:tax_return, status: :file_accepted, year: 2018),
        build(:tax_return, status: :prep_preparing, year: 2019)
      ] }

      it "does not change their status" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.tax_returns.map(&:status)).to match_array(%w[file_accepted prep_preparing])
      end
    end
  end
end
