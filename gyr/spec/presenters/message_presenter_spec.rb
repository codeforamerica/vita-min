require "rails_helper"

RSpec.describe MessagePresenter do
  context "with messages from different days" do
    let(:document_note_double) { double(SyntheticNote) }
    let(:outbound_call_note_double) { double(SyntheticNote) }
    let(:day1) { DateTime.new(2019, 10, 5, 8, 1).utc }
    let(:day2) { DateTime.new(2020, 10, 5, 5, 1).utc }
    let(:client) { create :client }

    before do
      allow(SyntheticNote).to receive(:from_client_documents).with(client).and_return [document_note_double]
      allow(SyntheticNote).to receive(:from_outbound_calls).with(client).and_return [outbound_call_note_double]
      allow(document_note_double).to receive(:datetime).and_return day1
      allow(outbound_call_note_double).to receive(:datetime).and_return day2
    end

    it "correctly groups notes by day created" do
      incoming_text = create :incoming_text_message, client: client, received_at: day1 # UTC
      outgoing_text = create :outgoing_text_message, client: client, sent_at: day2
      incoming_email = create :incoming_email, client: client, received_at: day1
      incoming_portal_message = create :incoming_portal_message, client: client, created_at: day1
      signed_document_message = SystemNote::SignedDocument.create(client: client, body: "You signed!", created_at: day1)
      all_notes_by_day = MessagePresenter.grouped_messages(client)

      expect(all_notes_by_day.keys).to eq [day1.beginning_of_day, day2.beginning_of_day]
      expect(all_notes_by_day[day1.beginning_of_day]).to eq [incoming_text, incoming_email, incoming_portal_message, signed_document_message, document_note_double]
      expect(all_notes_by_day[day2.beginning_of_day]).to eq [outgoing_text, outbound_call_note_double]
    end
  end
end