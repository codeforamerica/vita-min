# == Schema Information
#
# Table name: outgoing_text_messages
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
#  user_id         :bigint
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

  before do
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  describe "interaction tracking" do
    it_behaves_like "a user-initiated outgoing interaction" do
      let(:subject) { build :outgoing_text_message }
    end

    it_behaves_like "an outgoing interaction" do
      let(:subject) { build :outgoing_text_message }
    end

    context "for an automated message with no user" do
      let(:client) { create :client, first_unanswered_incoming_interaction_at: 4.business_days.ago }
      let(:message) { build :outgoing_text_message, client: client, user: nil }

      it "does not count as a user-initiated outgoing interaction" do
        expect do
          message.save
        end.not_to change { client.first_unanswered_incoming_interaction_at }
      end
    end
  end

  describe "#valid?" do
    describe "required fields" do
      context "without required fields" do
        let(:message) { OutgoingTextMessage.new }

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
          OutgoingTextMessage.new(
            user: create(:user),
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
          it "enqueues a job to send the text" do
            expect {
              message.save
            }.to have_enqueued_job.on_queue("default").with(message.id)
          end

          it "broadcasts the text message" do
            message.save
            expect(ClientChannel).to have_received(:broadcast_contact_record).with(message)
          end
        end
      end
    end

    context "with an unknown status" do
      let(:message) { build :outgoing_text_message, twilio_status: "unknown_status" }

      it "is invalid" do
        expect(message).not_to be_valid
        expect(message.errors).to include :twilio_status
      end
    end
  end

  describe "#to_phone_number" do
    let(:outgoing_text_message) { build :outgoing_text_message, to_phone_number: input_number }
    before { outgoing_text_message.valid? }

    context "with e164" do
      let(:input_number) { "+15005550006" }
      it "is valid" do
        expect(outgoing_text_message.errors).not_to include :to_phone_number
      end
    end

    context "without a + but otherwise correct" do
      let(:input_number) { "15005550006" }
      it "is not valid" do
        expect(outgoing_text_message.errors).to include :to_phone_number
      end
    end

    context "without a +1 but otherwise correct" do
      let(:input_number) { "5005550006" }

      it "is not valid" do
        expect(outgoing_text_message.errors).to include :to_phone_number
      end
    end

    context "with any non-numeric characters" do
      let(:input_number) { "+1500555-006" }

      it "is not valid" do
        expect(outgoing_text_message.errors).to include :to_phone_number
      end
    end
  end

  describe "#to" do
    let(:outgoing_text_message) { build :outgoing_text_message, to_phone_number: input_number }
    let(:input_number) { "+15005550006" }

    it "formats the provided phone number" do
      expect(outgoing_text_message.to).to eq "(500) 555-0006"
    end
  end

  describe "#formatted_time" do
    let(:message) { create :outgoing_text_message, sent_at: DateTime.new(2020, 2, 1, 2, 45, 1) }

    it "returns a human readable time" do
      expect(message.formatted_time).to eq "2:45 AM UTC"
    end
  end

  describe "scopes for statuses" do
    let!(:undelivered) { create :outgoing_text_message, twilio_status: "undelivered" }
    let!(:failed) { create :outgoing_text_message, twilio_status: "failed" }
    let!(:delivery_unknown) { create :outgoing_text_message, twilio_status: "delivery_unknown" }
    let!(:sent) { create :outgoing_text_message, twilio_status: "sent" }
    let!(:delivered) { create :outgoing_text_message, twilio_status: "delivered" }
    let!(:accepted) { create :outgoing_text_message, twilio_status: "accepted" }
    let!(:queued) { create :outgoing_text_message, twilio_status: "queued" }
    let!(:nil_status) { create :outgoing_text_message, twilio_status: nil }

    describe ".succeeded" do
      it "returns records with the right twilio statuses" do
        expect(described_class.succeeded).to match_array [sent, delivered]
      end
    end

    describe ".failed" do
      it "returns records with the right twilio statuses" do
        expect(described_class.failed).to match_array [undelivered, failed, delivery_unknown]
      end
    end

    describe ".in_progress" do
      it "returns records with the right twilio statuses" do
        expect(described_class.in_progress).to match_array [accepted, nil_status, queued]
      end
    end
  end
end
