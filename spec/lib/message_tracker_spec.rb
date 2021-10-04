require "rails_helper"

describe MessageTracker do
  let(:client) { create :client }
  subject { described_class.new(client: client, message_name: "sample_message") }

  describe "#record" do
    it "sets the datetime onto client#message_tracker" do
      time = DateTime.current
      subject.record(time)
      expect(client.reload.message_tracker["sample_message"]).to eq time.to_s
    end
  end

  describe "#sent_at" do
    it "rehydrates the time string as a DateTime object" do
      time = DateTime.current.beginning_of_minute
      subject.record(time)
      expect(subject.sent_at).to eq time
    end
  end

  describe "#already_sent?" do
    context "when there is a record of it having been sent" do
      before do
        subject.record(DateTime.current)
      end

      it "returns true" do
        expect(subject.already_sent?).to eq true
      end
    end

    context "when there is no record of it having been sent" do
      it "returns false" do
        expect(subject.already_sent?).to eq false
      end
    end
  end
end