require 'rails_helper'

describe RecentMessageSummaryService do
  describe ".messages" do
    context "given a client ID with no messages" do
      it "returns an empty hash" do
        expect(RecentMessageSummaryService.messages([1])).to eq({})
      end
    end

    context "given a client ID with an outbound message" do
      let(:time) { DateTime.new(2015, 10, 21, 0, 0, 0) }
      let(:client) { create(:client) }
      let(:user) { create(:user, name: "User Name") }
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

    context "given a client ID with an outbound message" do
      let(:time) { DateTime.new(2015, 10, 21, 0, 0, 0) }
      let(:client) { create(:client) }
      let(:user) { create(:user, name: "User Name") }
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
  end
end
