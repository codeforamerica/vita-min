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
    let!(:intake) { create(:intake, client: client, locale: :en) }
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }
    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
    end
    it "sets the client's triggered_still_needs_help_at timestamp" do
      expect do
        Timecop.freeze(fake_time) { described_class.trigger_still_needs_help_flow(client) }
      end.to change(client, :triggered_still_needs_help_at).from(nil).to(fake_time)
    end

    it "sends a message to the client" do
      described_class.trigger_still_needs_help_flow(client)
      expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with({
                                                                                                                     client: client,
                                                                                                                     locale: "en",
                                                                                                                     message: AutomatedMessage::ClosingSoon
                                                                                                                 })
    end

    context "with tax returns with status ready for review (aka intake ready)" do
      let(:tax_returns) do
        [
          build(:tax_return, :intake_ready, year: 2019),
          build(:tax_return, :intake_ready, year: 2018)
        ]
      end

      it "does not mark them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:state).uniq).to eq(["intake_ready"])
      end
    end

    context "with tax returns with status not ready (aka in progress)" do
      let(:tax_returns) do
        [
          build(:tax_return, :intake_in_progress, year: 2019),
          build(:tax_return, :intake_in_progress, year: 2018)
        ]
      end

      it "marks them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:state).uniq).to eq(["file_not_filing"])
      end
    end

    context "with tax returns with status intake_info_requested" do
      let(:tax_returns) do
        [
          build(:tax_return, :intake_info_requested, year: 2019),
          build(:tax_return, :intake_info_requested, year: 2018)
        ]
      end

      it "marks them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:state).uniq).to eq(["file_not_filing"])
      end
    end

    context "with tax returns with status intake_greeter_info_requested" do
      let(:tax_returns) do
        [
          build(:tax_return, :intake_greeter_info_requested, year: 2019),
          build(:tax_return, :intake_greeter_info_requested, year: 2018)
        ]
      end

      it "marks them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:status).uniq).to eq(["file_not_filing"])
      end
    end

    context "with tax returns with status intake_needs_doc_help" do
      let(:tax_returns) do
        [
          build(:tax_return, :intake_needs_doc_help, year: 2019),
          build(:tax_return, :intake_needs_doc_help, year: 2018)
        ]
      end

      it "marks them as not filing" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.reload.tax_returns.map(&:state).uniq).to eq(["file_not_filing"])
      end
    end

    context "with returns in other statuses" do
      let(:tax_returns) do
        [
          build(:tax_return, :file_accepted, year: 2018),
          build(:tax_return, :prep_preparing, year: 2019)
        ]
      end

      it "does not change their status" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.tax_returns.map(&:state)).to match_array(%w[file_accepted prep_preparing])
      end
    end

    context "with returns in a mix of statuses" do
      let(:tax_returns) do
        [
          build(:tax_return, :intake_greeter_info_requested, year: 2018),
          build(:tax_return, :prep_preparing, year: 2019)
        ]
      end

      it "changes only the statuses that are indicated to change" do
        described_class.trigger_still_needs_help_flow(client)
        expect(client.tax_returns.map(&:state)).to match_array(%w[intake_greeter_info_requested prep_preparing])
      end
    end
  end
end
