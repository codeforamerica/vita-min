require 'rails_helper'

describe RecentMessageSummaryService do
  describe ".messages" do
    context "given a client ID with no messages" do
      let(:client) { create(:client) }

      it "returns an empty hash" do
        expect(RecentMessageSummaryService.messages([client.id])).to eq({})
      end
    end

    context "with some messages" do
      let(:client) { create(:client, intake: create(:intake, preferred_name: "Client Name")) }
      let(:user) { create(:user, name: "User Name") }
      let!(:old_outgoing_text) { create :outgoing_text_message, created_at: DateTime.new(2021, 3, 17, 0, 0, 0), user: user, client: client, body: "Hello this is an old text" }
      let!(:old_outgoing_email) { create :outgoing_email, created_at: DateTime.new(2021, 3, 18, 0, 0, 0), user: user, client: client, body: "Hello this is an old email" }
      let!(:old_incoming_text) { create :incoming_text_message, created_at: DateTime.new(2021, 3, 19, 0, 0, 0), client: client, body: "Thank you for the old messages here is a text" }

      context "given a client ID with most recent message type: outgoing email" do
        let(:time) { DateTime.new(2021, 3, 21, 0, 0, 0) }

        before do
          Timecop.freeze(time) do
            create(:outgoing_email, user: user, client: client, body: "Have a nice day")
          end
        end

        it "returns the message body, author, and date" do
          expect(RecentMessageSummaryService.messages([client.id])).to(
            eq({client.id => {body: "Have a nice day", date: time, author: "User Name"}}))
        end
      end

      context "given a client ID with most recent message type: outgoing text message" do
        let(:time) { DateTime.new(2021, 3, 21, 0, 0, 0) }
        before do
          Timecop.freeze(time) do
            create(:outgoing_text_message, user: user, client: client, body: "Have a nice day")
          end
        end

        it "returns the message body, author, and date" do
          expect(RecentMessageSummaryService.messages([client.id])).to(
            eq({client.id => {body: "Have a nice day", date: time, author: "User Name"}}))
        end
      end

      context "given a client ID with most recent message type: incoming email" do
        let(:time) { DateTime.new(2021, 3, 21, 0, 0, 0) }
        before do
          Timecop.freeze(time) do
            create(:incoming_email, client: client, body_plain: "Have a nice day")
          end
        end

        it "returns the message body, author, and date" do
          expect(RecentMessageSummaryService.messages([client.id])).to(
            eq({client.id => {body: "Have a nice day", date: time, author: "Client Name"}}))
        end
      end

      context "given a client ID with most recent message type: incoming text message" do
        let(:time) { DateTime.new(2021, 3, 21, 0, 0, 0) }
        before do
          Timecop.freeze(time) do
            create(:incoming_text_message, client: client, body: "Have a nice day")
          end
        end

        it "returns the message body, author, and date" do
          expect(RecentMessageSummaryService.messages([client.id])).to(
            eq({client.id => {body: "Have a nice day", date: time, author: "Client Name"}}))
        end
      end
    end
  end
end
