require 'rails_helper'

RSpec.describe IntercomService do
  let(:fake_intercom) { instance_double(Intercom::Client) }

  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:intercom, :intercom_access_token).and_return("fake_access_token")
    allow(Intercom::Client).to receive(:new).with(token: "fake_access_token").and_return(fake_intercom)
  end

  describe "#create_intercom_message_from_email" do
    context "no existing contact with email" do
      let(:intake) { create :intake, email_address: "beep@example.com" }
      let(:incoming_email) { create :incoming_email, client: intake.client, stripped_text: "hi i would like some help" }

      before do
        allow(subject).to receive(:contact_id_from_email).with(intake.email_address).and_return(nil)
        allow(fake_intercom).to receive_message_chain(:contacts, :create, :id).and_return("fake_new_contact_id")
        allow(subject).to receive(:create_new_intercom_thread).with("fake_new_contact_id", incoming_email.body)
      end

      it "creates a new contact and creates a new message with the new contact" do
        subject.create_intercom_message_from_email(incoming_email)
        expect(subject).to have_received(:create_new_intercom_thread).with("fake_new_contact_id", "hi i would like some help")
      end
    end

    context "with existing contact with email and conversation in intercom" do
      let(:intake) { create :intake, email_address: "beep@example.com" }
      let(:incoming_email) { create :incoming_email, client: intake.client, stripped_text: "is anyone still there?" }

      before do
        allow(subject).to receive(:contact_id_from_email).with(intake.email_address).and_return("fak3_1d")
        allow(subject).to receive(:most_recent_conversation).with("fak3_1d").and_return("fake_convo_id")
        allow(subject).to receive(:reply_to_existing_intercom_thread).with(intake.email_address, "fak3_1d", incoming_email.body)
      end

      it "creates a new message with the existing contact and conversation thread" do
        subject.create_intercom_message_from_email(incoming_email)
        expect(subject).to have_received(:reply_to_existing_intercom_thread).with("beep@example.com", "fak3_1d", "is anyone still there?")
      end
    end
  end

  # describe ".create_lead_by_email" do
  #   let(:contact_attr) do
  #     {
  #       email: "sqaush@example.com",
  #       name: "Sally Squash"
  #     }
  #   end
  #
  #   it "creates a new lead with email and name" do
  #     subject.create_lead_by_email("")
  #     expect(fake_intercom.contacts).to have_received(:create).with(contact_attr)
  #   end
  # end
end