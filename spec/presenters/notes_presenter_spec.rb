require "rails_helper"

RSpec.describe NotesPresenter do
  describe "#grouped_notes" do
    let(:vita_partner) { create :organization }
    let(:client) { create :client, vita_partner: vita_partner, intake: (create :intake) }
    let(:params) { { client_id: client.id } }
    let(:user) { create :admin_user }

    before do
      create :note # unrelated note
      create :system_note # unrelated system note
    end

    context "with notes from different days" do
      let(:document_note_double) { double(SyntheticNote) }
      let(:outbound_call_note_double) { double(SyntheticNote) }
      let(:day1){ DateTime.new(2019, 10, 5, 8, 1).utc }
      let(:day2){ DateTime.new(2020, 10, 5, 5, 1).utc }

      before do
        allow(SyntheticNote).to receive(:from_client_documents).with(client).and_return [document_note_double]
        allow(SyntheticNote).to receive(:from_outbound_calls).with(client).and_return [outbound_call_note_double]
        allow(document_note_double).to receive(:created_at).and_return day1
        allow(outbound_call_note_double).to receive(:created_at).and_return day2
      end

      it "correctly groups notes by day created" do
        day1_client_note = create :note, client: client, created_at: day1 # UTC
        day2_client_note = create :note, client: client, created_at: day2
        day1_system_note = create :system_note, client: client, created_at: day1
        all_notes_by_day = NotesPresenter.grouped_notes(client)

        expect(all_notes_by_day.keys).to eq [day1.beginning_of_day, day2.beginning_of_day]
        expect(all_notes_by_day[day1.beginning_of_day]).to eq [day1_client_note, day1_system_note, document_note_double]
        expect(all_notes_by_day[day2.beginning_of_day]).to eq [day2_client_note, outbound_call_note_double]
      end
    end

  end
end
