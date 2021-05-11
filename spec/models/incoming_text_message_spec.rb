# == Schema Information
#
# Table name: incoming_text_messages
#
#  id                :bigint           not null, primary key
#  body              :string
#  from_phone_number :string           not null
#  received_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint           not null
#
# Indexes
#
#  index_incoming_text_messages_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
require "rails_helper"

RSpec.describe IncomingTextMessage, type: :model do
  context "on create" do
    it_behaves_like "an incoming interaction" do
      let(:subject) { build :incoming_text_message }
    end
  end

  describe "#valid?" do
    describe "required fields" do
      context "without required fields" do
        let(:message) { described_class.new }

        it "is not valid and adds an error to each field" do
          expect(message).not_to be_valid
          expect(message.errors).to include :body # since there's no attachment
          expect(message.errors).to include :from_phone_number
          expect(message.errors).to include :received_at
          expect(message.errors).to include :client
        end
      end

      context "with all required fields" do
        let(:message) do
          described_class.new(
            body: "hi",
            from_phone_number: "+15005550006",
            received_at: DateTime.now,
            client: create(:client)
          )
        end

        it "is valid and does not have errors" do
          expect(message).to be_valid
          expect(message.errors).to be_blank
        end
      end
    end

    describe "requires either an attachment or a body" do
      context "with no attachment or body" do
        let(:message) { build(:incoming_text_message, body: "") }

        it "is not valid and adds an error to body" do
          expect(message).not_to be_valid
          expect(message.errors).to include :body
        end
      end

      context "with a body and no attachment" do
        let(:message) { build(:incoming_text_message, body: "hello") }

        it "is valid" do
          expect(message).to be_valid
        end
      end

      context "with an attachment and no body" do
        let(:document) { build :document, document_type: DocumentTypes::TextMessageAttachment.key }
        let(:message) { build :incoming_text_message, body: nil, documents: [document]  }

        it "is valid" do
          expect(message).to be_valid
        end
      end

      context "with no attachment and a purely-whitespace body" do
        let(:message) { build :incoming_text_message, body: " ", documents: [] }

        it "is valid" do
          expect(message).to be_valid
        end
      end
    end
  end

  describe "#from_phone_number" do
    let(:incoming_text_message) { build :incoming_text_message, from_phone_number: input_number }
    before { incoming_text_message.valid? }

    context "with e164" do
      let(:input_number) { "+15005550006" }
      it "is valid" do
        expect(incoming_text_message.errors).not_to include :from_phone_number
      end
    end

    context "without a + but otherwise correct" do
      let(:input_number) { "15005550006" }
      it "is not valid" do
        expect(incoming_text_message.errors).to include :from_phone_number
      end
    end

    context "without a +1 but otherwise correct" do
      let(:input_number) { "5005550006" }

      it "is not valid" do
        expect(incoming_text_message.errors).to include :from_phone_number
      end
    end

    context "with any non-numeric characters" do
      let(:input_number) { "+1500555-006" }

      it "is not valid" do
        expect(incoming_text_message.errors).to include :from_phone_number
      end
    end
  end

  describe "#from" do
    let(:incoming_text_message) { build :incoming_text_message, from_phone_number: input_number }
    let(:input_number) { "+15005550006" }

    it "formats the provided phone number" do
      expect(incoming_text_message.from).to eq "(500) 555-0006"
    end
  end

  describe "#formatted_time" do
    let(:message) { create :incoming_text_message, received_at: DateTime.new(2020, 2, 1, 2, 45, 1) }

    it "returns a human readable time" do
      expect(message.formatted_time).to eq "2:45 AM UTC"
    end
  end
end
