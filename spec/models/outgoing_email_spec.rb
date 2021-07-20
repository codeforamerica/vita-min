# == Schema Information
#
# Table name: outgoing_emails
#
#  id             :bigint           not null, primary key
#  body           :string           not null
#  mailgun_status :string           default("sending")
#  sent_at        :datetime
#  subject        :string           not null
#  to             :citext           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_id      :bigint           not null
#  message_id     :string
#  user_id        :bigint
#
# Indexes
#
#  index_outgoing_emails_on_client_id   (client_id)
#  index_outgoing_emails_on_created_at  (created_at)
#  index_outgoing_emails_on_message_id  (message_id)
#  index_outgoing_emails_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe OutgoingEmail, type: :model do
  before do
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  context "interaction tracking" do
    it_behaves_like "a user-initiated outgoing interaction" do
      let(:subject) { build :outgoing_email }
    end

    it_behaves_like "an outgoing interaction" do
      let(:subject) { build :outgoing_text_message }
    end

    context "for an automated email with no user" do
      let(:client) { create :client, first_unanswered_incoming_interaction_at: 4.business_days.ago }
      let(:email) { build :outgoing_email, client: client, user: nil }

      it "does not count as a user-initiated outgoing interaction" do
        expect do
          email.save
        end.not_to change { client.first_unanswered_incoming_interaction_at }
      end
    end
  end

  describe "#valid?" do
    describe "required fields" do
      context "without required fields" do
        let(:email) { OutgoingEmail.new }

        it "is not valid and adds an error to each field" do
          expect(email).not_to be_valid
          expect(email.errors).to include :client
          expect(email.errors).to include :to
          expect(email.errors).to include :subject
          expect(email.errors).to include :body
        end
      end

      context "with all required fields" do
        let(:message) do
          OutgoingEmail.new(
              client: create(:client),
              to: "someone@example.com",
              subject: "this is a subject",
              body: "hi",
              user: create(:user)
              )
        end

        it "is valid and does not have errors" do
          expect(message).to be_valid
          expect(message.errors).to be_blank
        end
      end
    end

    describe "#mailgun_status" do
      context "with an unknown status" do
        let(:email) { build :outgoing_email, mailgun_status: "unfamiliar_status" }

        it "adds an error and is not valid" do
          expect(email).not_to be_valid
          expect(email.errors).to include :mailgun_status
        end
      end
    end
  end

  context "after create" do
    let(:message) do
      OutgoingEmail.new(
        client: create(:client),
        to: "someone@example.com",
        subject: "this is a subject",
        body: "hi",
        sent_at: DateTime.now,
        user: create(:user),
        attachment: fixture_file_upload("test-pattern.png"),
      )
    end

    it "enqueues delivery of the message" do
      expect {
        message.save
      }.to have_enqueued_job(SendOutgoingEmailJob)
    end

    it "broadcasts a message" do
      message.save
      expect(ClientChannel).to have_received(:broadcast_contact_record).with(message)
    end
  end

  context "default mailgun status" do
    let(:outgoing_email) { build :outgoing_email, mailgun_status: "delivered" }

    context "when the status is blank" do
      let(:outgoing_email) do
        OutgoingEmail.new(
          client: create(:client),
          to: "someone@example.com",
          subject: "this is a subject",
          body: "hi",
          sent_at: DateTime.now,
          user: create(:user),
          attachment: fixture_file_upload("test-pattern.png"),
          )
      end

      it "defaults the status to sending" do
        outgoing_email.save
        expect(outgoing_email.reload.mailgun_status).to eq "sending"
      end
    end
  end

  describe "scopes for statuses" do
    let!(:opened) { create :outgoing_email, mailgun_status: "opened" }
    let!(:delivered) { create :outgoing_email, mailgun_status: "delivered" }
    let!(:failed) { create :outgoing_email, mailgun_status: "failed" }
    let!(:permanent_fail) { create :outgoing_email, mailgun_status: "permanent_fail" }
    let!(:nil_status) { create :outgoing_email, mailgun_status: nil }
    let!(:sending) { create :outgoing_email, mailgun_status: "sending" }

    describe ".succeeded" do
      it "returns records with the right mailgun statuses" do
        expect(described_class.succeeded).to match_array [opened, delivered]
      end
    end

    describe ".failed" do
      it "returns records with the right mailgun statuses" do
        expect(described_class.failed).to match_array [failed, permanent_fail]
      end
    end

    describe ".in_progress" do
      it "returns records with the right mailgun statuses" do
        expect(described_class.in_progress).to match_array [nil_status, sending]
      end
    end
  end

  describe "display methods for templates" do
    let!(:delivered) { create :outgoing_email, mailgun_status: "delivered" }
    describe "datetime" do
      it "returns created_at timestamp" do
        expect(delivered.datetime).to eq delivered.created_at
      end
    end

    describe "author" do
      before do
        delivered.user.update!(name: "User Name")
      end

      it "returns the user name" do
        expect(delivered.author).to eq "User Name"
      end
    end
  end
end
