# == Schema Information
#
# Table name: system_text_messages
#
#  id              :bigint           not null, primary key
#  body            :string           not null
#  sent_at         :datetime         not null
#  to_phone_number :string           not null
#  twilio_sid      :string
#  twilio_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :bigint           not null
#
# Indexes
#
#  index_system_text_messages_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
require "rails_helper"

RSpec.describe SystemTextMessage, type: :model do
  before do
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  describe "required fields" do
    context "without required fields" do
      let(:message) { SystemTextMessage.new }

      it "is not valid and adds an error to each field" do
        expect(message).not_to be_valid
        expect(message.errors).to include :client
        expect(message.errors).to include :sent_at
        expect(message.errors).to include :body
        expect(message.errors).to include :to_phone_number
      end
    end

    context "with all required fields" do
      let(:message) do
        SystemTextMessage.new(
          client: create(:client),
          body: "hi",
          sent_at: DateTime.now,
          to_phone_number: "+15005550006"
        )
      end

      it "is valid and does not have errors" do
        expect(message).to be_valid
        expect(message.errors).to be_blank
      end

      context "after create" do
        it "enqueues a job to sent the text" do
          expect {
            message.save
          }.to have_enqueued_job.on_queue("default").with(message)
        end

        it "broadcasts the text message" do
          message.save
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(message)
        end
      end
    end
  end

  describe "#to_phone_number" do
    let(:message) { build :system_text_message, to_phone_number: input_number }
    before { message.valid? }

    context "with e164" do
      let(:input_number) { "+15005550006" }
      it "is valid" do
        expect(message.errors).not_to include :to_phone_number
      end
    end

    context "without a + but otherwise correct" do
      let(:input_number) { "15005550006" }
      it "is not valid" do
        expect(message.errors).to include :to_phone_number
      end
    end

    context "without a +1 but otherwise correct" do
      let(:input_number) { "5005550006" }

      it "is not valid" do
        expect(message.errors).to include :to_phone_number
      end
    end

    context "with any non-numeric characters" do
      let(:input_number) { "+1500555-006" }

      it "is not valid" do
        expect(message.errors).to include :to_phone_number
      end
    end
  end

  describe "#formatted_time" do
    let(:message) { create :system_text_message, sent_at: DateTime.new(2020, 2, 1, 2, 45, 1) }

    it "returns a human readable time" do
      expect(message.formatted_time).to eq "2:45 AM UTC"
    end
  end
end
