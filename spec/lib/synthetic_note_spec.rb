require 'rails_helper'

describe SyntheticNote do
  describe ".from_client_documents" do
    let(:client) { create :client, intake: (create :intake) }
    let(:user) { create :user }

    context "with documents on one day" do
      let(:day1) { DateTime.new(2019, 10, 5, 8, 1).utc }
      let!(:documents) { create_list(:document, 5, created_at: day1, client: client, uploaded_by: client) }

      it "groups recently created documents into one message" do
        result = SyntheticNote.from_client_documents(client)
        expect(result[0].created_at).to eq day1
        expect(result[0].body).to eq "Client added 5 documents."
      end

      context "when there are documents uploaded by the system or a user" do
        before do
          # Creates more documents that ARENT added to the count
          create_list(:document, 2, created_at: day1, client: client)
          create_list(:document, 1, created_at: day1, client: client, uploaded_by: create(:user))
        end

        it "does not include docs that are not uploaded by the client" do
          result = SyntheticNote.from_client_documents(client)
          expect(result[0].body).to eq "Client added 5 documents."
        end
      end
    end

    context "with documents on multiple days" do
      let(:day1) { DateTime.new(2019, 10, 5, 1).utc }
      let(:day2) { DateTime.new(2019, 10, 8, 1).utc }
      let(:day2_noon) { DateTime.new(2019, 10, 8, 12).utc }

      before do
        create_list(:document, 1, created_at: day1, client: client, uploaded_by: client)
        create_list(:document, 2, created_at: day2, client: client, uploaded_by: client)
        create_list(:document, 2, created_at: day2_noon, client: client, uploaded_by: client)
      end

      it "groups recently created documents into one message" do
        result = SyntheticNote.from_client_documents(client)
        expect(result[0].created_at).to eq day1
        expect(result[0].body).to eq "Client added 1 document."
        expect(result[1].created_at).to eq day2_noon
        expect(result[1].body).to eq "Client added 4 documents."
      end
    end

    context "with outbound calls" do
      let(:day1) { DateTime.new(2019, 10, 5, 8, 1).utc }
      let(:day2) { DateTime.new(2020, 10, 5, 5, 1).utc }
      let!(:outbound_call_completed) { create :outbound_call, twilio_status: "completed", created_at: day1, twilio_call_duration: 75, client: client, user: user, note: "I talked to them!" }
      let!(:outbound_call_queued) { create :outbound_call, twilio_status: "queued", created_at: day2, client: client, user: user }
      it "does not include outbound_calls in status queued" do
        result = SyntheticNote.from_outbound_calls(client)
        expect(result.length).to eq 1
        expect(result[0].body).to include "Called by #{user.name}. Call was completed and lasted 1m15s."
        expect(result[0].body).to match /^I talked to them!$/
      end
    end
  end
end
