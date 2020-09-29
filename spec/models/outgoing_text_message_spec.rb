# == Schema Information
#
# Table name: outgoing_text_messages
#
#  id            :bigint           not null, primary key
#  body          :string           not null
#  sent_at       :datetime         not null
#  twilio_sid    :string
#  twilio_status :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_outgoing_text_messages_on_client_id  (client_id)
#  index_outgoing_text_messages_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe OutgoingTextMessage, type: :model do
  describe "required fields" do
    context "without required fields" do
      let(:message) { OutgoingTextMessage.new }

      it "is not valid and adds an error to each field" do
        expect(message).not_to be_valid
        expect(message.errors).to include :user
        expect(message.errors).to include :client
        expect(message.errors).to include :sent_at
        expect(message.errors).to include :body
      end
    end

    context "with all required fields" do
      let(:message) do
        OutgoingTextMessage.new(
          user: create(:user),
          client: create(:client),
          body: "hi",
          sent_at: DateTime.now
        )
      end

      it "is valid and does not have errors" do
        expect(message).to be_valid
        expect(message.errors).to be_blank
      end
    end
  end

  describe "#formatted_time" do
    let(:message) { create :outgoing_text_message, sent_at: DateTime.new(2020, 2, 1, 2, 45, 1) }

    it "returns a human readable time" do
      expect(message.formatted_time).to eq "2:45 AM UTC"
    end
  end
end
