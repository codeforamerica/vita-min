require "rails_helper"

RSpec.describe NotesPresenter do
  describe "#grouped_notes" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: (create :intake) }
    let(:params) { { client_id: client.id } }
    let(:user) { create :user, vita_partner: vita_partner }

    before do
      create :note # unrelated note
      create :system_note # unrelated system note
    end

    context "with notes from different days" do

      it "correctly groups notes by day created" do
        day1 = DateTime.new(2019, 10, 5, 8, 1).utc
        day2 = DateTime.new(2020, 10, 5, 5, 1).utc
        day1_client_note = create :note, client: client, created_at: day1 # UTC
        day2_client_note = create :note, client: client, created_at: day2
        day1_system_note = create :system_note, client: client, created_at: day1

        all_notes_by_day = NotesPresenter.grouped_notes(client)


        expect(all_notes_by_day.keys).to eq [day1.beginning_of_day, day2.beginning_of_day]

        expect(all_notes_by_day[day1.beginning_of_day]).to eq [day1_client_note, day1_system_note]
        expect(all_notes_by_day[day2.beginning_of_day]).to eq [day2_client_note]
      end
    end

    context "with documents on one day" do
      let(:day1) { DateTime.new(2019, 10, 5, 8, 1).utc }
      let!(:documents) { create_list(:document, 5, created_at: day1, client: client) }

      it "groups recently created documents into one message" do
        result = NotesPresenter.grouped_notes(client)
        expect(result[day1.beginning_of_day][0].created_at).to eq day1
        expect(result[day1.beginning_of_day][0].body).to eq "Client added 5 documents."
      end
    end

    context "with documents on multiple days" do
      let(:day1) { DateTime.new(2019, 10, 5, 1).utc }
      let(:day2) { DateTime.new(2019, 10, 8, 1).utc }
      let(:day2_noon) { DateTime.new(2019, 10, 8, 12).utc }

      before do
        create_list(:document, 1, created_at: day1, client: client)
        create_list(:document, 2, created_at: day2, client: client)
        create_list(:document, 2, created_at: day2_noon, client: client)
      end

      it "groups recently created documents into one message" do
        result = NotesPresenter.grouped_notes(client)
        expect(result[day1.beginning_of_day][0].created_at).to eq day1
        expect(result[day1.beginning_of_day][0].body).to eq "Client added 1 document."
        expect(result[day2.beginning_of_day][0].created_at).to eq day2_noon
        expect(result[day2.beginning_of_day][0].body).to eq "Client added 4 documents."
      end
    end

    context "with outbound calls" do
      let(:day1) { DateTime.new(2019, 10, 5, 8, 1).utc }
      let(:day2) { DateTime.new(2020, 10, 5, 5, 1).utc }
      let!(:outbound_call_completed) { create :outbound_call, twilio_status: "completed", created_at: day1, call_duration: "75", client: client, user: user, note: "I talked to them!" }
      let!(:outbound_call_queued) { create :outbound_call, twilio_status: "queued", created_at: day2, client: client, user: user }
      it "does not include outbound_calls in status queued" do
        result = NotesPresenter.grouped_notes(client)
        notes = result.values.flatten
        expect(notes.length).to eq 1
        puts(result.values)
        expect(notes[0].body).to include "Called by Gary Gnome. Call was completed and lasted 1m15s."
        expect(notes[0].body).to include "I talked to them!"
      end
    end
  end
end
