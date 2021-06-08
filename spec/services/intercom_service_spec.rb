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
      let(:incoming_email) { create :incoming_email, client: intake.client, stripped_text: "is anyone still there?" }

      before do
        # not sure what this should return when there is no matching contact - i assumed nil but i'd check by testing in the console
        # allow(fake_intercom).to receive_message_chain(:contacts, :find).with({ email: "beep@example.com" }).and_return(nil)
      end

      it "creates a new contact and creates a new message with the new contact" do
        # subject.create_intercom_message_from_email(incoming_email)
        #
        # expect()
      end
    end

    context "with existing contact with email" do
      let(:intake) { create :intake, email_address: "beep@example.com" }
      let(:incoming_email) { create :incoming_email, client: intake.client, stripped_text: "is anyone still there?" }

      before do
        # replace this fake_contact with a contact copy-pasted from the command line (returned from intercom test account)
        fake_contact = {
          "data": [
            "id": "fak3_1d"
          ]
        }
        allow(fake_intercom).to receive_message_chain(:contacts, :find).with({ email: "beep@example.com" }).and_return(fake_contact)
        allow(fake_intercom).to receive_message_chain(:messages, :create)
      end

      it "creates a new message with the existing contact" do
        subject.create_intercom_message_from_email(incoming_email)

        message_details = {
          from: {
            type: "contact",
            id: "fak3_1d",
          },
          body: "is anyone still there?"
        }
        expect(fake_intercom).to have_received_message_chain(:messages, :create).with(message_details)
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