# == Schema Information
#
# Table name: outgoing_emails
#
#  id             :bigint           not null, primary key
#  body           :string           not null
#  mailgun_status :string
#  sent_at        :datetime         not null
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
#  index_outgoing_emails_on_client_id  (client_id)
#  index_outgoing_emails_on_user_id    (user_id)
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
    it_behaves_like "an outgoing interaction" do
      let(:subject) { build :outgoing_email }
    end

    context "for an automated email with no user" do
      let(:client) { create :client, first_unanswered_incoming_interaction_at: 4.business_days.ago }
      let(:email) { build :outgoing_email, client: client, user: nil }

      it "does not count as an outgoing interaction" do
        expect do
          email.save
        end.not_to change { client.first_unanswered_incoming_interaction_at }
      end
    end
  end

  describe "required fields" do
    context "without required fields" do
      let(:email) { OutgoingEmail.new }

      it "is not valid and adds an error to each field" do
        expect(email).not_to be_valid
        expect(email.errors).to include :client
        expect(email.errors).to include :to
        expect(email.errors).to include :subject
        expect(email.errors).to include :body
        expect(email.errors).to include :sent_at
      end
    end

    context "with all required fields" do
      let(:message) do
        OutgoingEmail.new(
            client: create(:client),
            to: "someone@example.com",
            subject: "this is a subject",
            body: "hi",
            sent_at: DateTime.now,
            user: create(:user)
            )
      end

      it "is valid and does not have errors" do
        expect(message).to be_valid
        expect(message.errors).to be_blank
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
        attachment: fixture_file_upload("attachments/test-pattern.png"),
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

  context "before create" do
    let(:outgoing_email) { build :outgoing_email, mailgun_status: "accepted" }
    context "when a status is already set" do
      it "does not overwrite the status" do
        outgoing_email.save
        expect(outgoing_email.reload.mailgun_status).to eq "accepted"
      end
    end

    context "when the status is blank" do
      let(:outgoing_email) { build :outgoing_email, mailgun_status: nil }

      it "defaults the status to sending" do
        outgoing_email.save
        expect(outgoing_email.reload.mailgun_status).to eq "sending"
      end
    end
  end
end
