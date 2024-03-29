require 'rails_helper'

RSpec.describe IntercomService do
  let(:fake_intercom) { instance_double(Intercom::Client) }
  let(:fake_contacts) { instance_double(Intercom::Service::Contact) }
  let(:fake_conversation_service) { instance_double(Intercom::Service::Conversation) }
  let(:fake_conversation) { instance_double(Intercom::Conversation) }
  let(:client) { create(:client, intake: build(:intake, email_address: "beep@example.com")) }
  let(:contact_role) { "user" }
  let(:fake_contact) { OpenStruct.new(id: "9999", type: "contact", role: contact_role, flat_store: nil) }
  let(:body) { "hi i want some help getting my refund thx have a nice day" }

  before do
    allow(fake_intercom).to receive(:messages).and_return(double)
    allow(fake_intercom.messages).to receive(:create)

    allow(fake_intercom).to receive(:contacts).and_return(fake_contacts)
    allow(fake_intercom.contacts).to receive(:search)
    allow(fake_intercom.contacts).to receive(:create).and_return(fake_contact)

    allow(fake_intercom).to receive(:conversations).and_return(fake_conversation_service)
    allow(fake_conversation_service).to receive(:search).and_return([])
    allow(fake_intercom.conversations).to receive(:reply)

    @test_environment_credentials.merge!(intercom: { intercom_access_token: "fake_access_token", secure_mode_secret_key: "a-fake-key-to-use-for-hashing" })
    allow(Intercom::Client).to receive(:new).with(token: "fake_access_token").and_return(fake_intercom)
    described_class.instance_variable_set(:@intercom, nil)
  end

  describe ".create_message" do
    context "when documents are attached" do
      let(:client) { create(:client) }
      it "appends a link to the message body" do
        described_class.create_message(body: body, email_address: nil, phone_number: nil, has_documents: true, client: client)
        expect(fake_intercom.messages).to(
          have_received(:create).with(
            hash_including(
              {
                body: body +
                  " [client sent an attachment, see #{Rails.application.routes.url_helpers.hub_client_documents_url(client_id: client.id)}]"
              }
            )
          )
        )
      end
    end

    context "when the body is blank" do
      it "does not send a message in Intercom" do
        described_class.create_message(body: "", email_address: "example@example.com", phone_number: "+1-555-555-1212", client: nil, has_documents: false)
        expect(fake_intercom.messages).not_to have_received(:create)
      end
    end

    context "when there is no pre-existing Intercom user" do
      let(:contact_role) { "lead" }
      it "creates a new Intercom user and creates a new message from them" do
        described_class.create_message(body: "hi i want some help getting my refund thx have a nice day", email_address: "example@example.com", phone_number: "+1-555-555-1212", client: nil, has_documents: false)
        expect(fake_intercom.contacts).to have_received(:create).with(
          {
            role: contact_role,
            phone: "+1-555-555-1212",
            email: "example@example.com",
          }
        )
        expect(fake_intercom.messages).to have_received(:create).with(
          body: "hi i want some help getting my refund thx have a nice day",
          from: { id: "9999", type: contact_role } # TODO: Are we sure type: contact_role is required and correct for create?
        )
      end

      context "when a client is provided" do
        let(:client) { create(:client) }
        let(:contact_role) { "user" }

        it "creates a new Intercom user w/ client ID & name & creates a new message from them" do
          described_class.create_message(body: body, email_address: "example@example.com", phone_number: "+1-555-555-1212", client: client, has_documents: false)
          expect(fake_intercom.contacts).to have_received(:create).with(
            {
              role: contact_role,
              phone: "+1-555-555-1212",
              email: "example@example.com",
              external_id: client.id.to_s,
              client: client.id.to_s,
              name: client.legal_name,
            }
          )
          expect(fake_intercom.messages).to have_received(:create).with(
            body: "hi i want some help getting my refund thx have a nice day",
            from: { id: "9999", type: contact_role }
          )
        end
      end
    end

    context "when creating a new Intercom thread" do
      before do
        allow(fake_intercom.conversations).to receive(:search).and_return []
      end

      context "finding the pre-existing Intercom contact" do
        before do
          allow(fake_intercom.contacts).to receive(:search).and_return [fake_contact]
        end

        context "when a client is provided and they have an Intercom contact" do
          let(:client) { create(:intake).client }

          it "uses that existing Intercom contact" do
            described_class.create_message(body: "hi i want some help getting my refund thx have a nice day", email_address: nil, phone_number: nil, client: client, has_documents: false)
            expect(fake_intercom.contacts).to have_received(:search).once
            expect(fake_intercom.contacts).to have_received(:search).with(
              {
                "query": {
                  "field": 'external_id',
                  "operator": '=',
                  "value": client.id.to_s
                }
              }
            )

            expect(fake_intercom.messages).to have_received(:create).with(
              {
                from: { type: fake_contact.role, id: fake_contact.id }, body: body
              }
            )
          end
        end

        context "when an email address is provided" do
          let(:fake_email_address) { "example@example.com" }
          it "uses that existing Intercom contact" do
            described_class.create_message(body: body, email_address: fake_email_address, phone_number: nil, client: nil, has_documents: false)

            expect(fake_intercom.contacts).to have_received(:search).with(
              {
                "query": {
                  "field": 'email',
                  "operator": '=',
                  "value": fake_email_address
                }
              }
            )
            expect(fake_intercom.contacts).to have_received(:search).once
            expect(fake_intercom.messages).to have_received(:create).with(
              {
                from: { type: fake_contact.role, id: fake_contact.id }, body: body
              }
            )
          end
        end

        context "when a phone number is provided" do
          let(:fake_phone_number) { "+1-585-555-1212" }

          it "uses that existing Intercom contact" do
            described_class.create_message(body: body, email_address: nil, phone_number: fake_phone_number, client: nil, has_documents: false)

            expect(fake_intercom.contacts).to have_received(:search).once
            expect(fake_intercom.contacts).to have_received(:search).with(
              {
                "query": {
                  "field": 'phone',
                  "operator": '=',
                  "value": fake_phone_number
                }
              }
            )

            expect(fake_intercom.messages).to have_received(:create).with(
              {
                from: { type: fake_contact.role, id: fake_contact.id }, body: body
              }
            )
          end
        end
      end
    end

    context "when replying to an existing Intercom thread" do
      context "when a client is provided and they have an Intercom contact and conversation" do
        before do
          allow(fake_conversation_service).to receive(:search).and_return([fake_conversation])
          allow(fake_conversation).to receive(:id).and_return(9999)
          allow(fake_intercom.contacts).to receive(:search).and_return [fake_contact]
        end

        let(:client) { create(:intake).client }

        it "uses that existing Intercom contact and most recent conversation" do
          described_class.create_message(body: "hi i want some help getting my refund thx have a nice day", email_address: nil, phone_number: nil, client: client, has_documents: false)
          expect(fake_intercom.contacts).to have_received(:search).once
          expect(fake_intercom.contacts).to have_received(:search).with(
            {
              "query": {
                "field": 'external_id',
                "operator": '=',
                "value": client.id.to_s
              }
            }
          )
          expect(fake_intercom.conversations).to(
            have_received(:reply).with(
              {
                id: 9999,
                intercom_user_id: fake_contact.id,
                type: 'user',
                message_type: 'comment',
                body: body
              }
            )
          )
        end
      end
    end
  end

  describe ".inform_client_of_handoff" do
    let(:fake_send_automated_message) { instance_double(SendAutomatedMessage, send_messages: nil) }

    before do
      allow(SendAutomatedMessage).to receive(:new).and_return(fake_send_automated_message)
    end

    it "returns if no client is provided" do
      described_class.inform_client_of_handoff(client: nil, send_sms: nil, send_email: nil)
      expect(SendAutomatedMessage).not_to have_received(:new)
    end

    it "sends an automated message" do
      client = create(:client)
      described_class.inform_client_of_handoff(client: client, send_sms: true, send_email: true)
      expect(SendAutomatedMessage).to(
        have_received(:new)
          .with(
            message: AutomatedMessage::IntercomForwarding,
            sms: true,
            email: true,
            client: client
          )
      )
      expect(fake_send_automated_message).to have_received(:send_messages)
    end
  end

  describe ".intercom_api" do
    let(:params) {
      {
        body: body,
        from: {
          type: fake_contact.role,
          id: fake_contact.id
        }
      }
    }

    context "when there's an upstream authentication failure" do
      before do
        allow(fake_intercom.messages).to receive(:create).with(params) {
          raise Intercom::AuthenticationError.new("fake error")
        }
      end

      it "fails after a number of retries" do
        # FIXME: Confirm that datadog counter was incremented by expected amount (3)
        expect {
          described_class.intercom_api(:messages, :create, params)
        }.to raise_error(Intercom::AuthenticationError, "Failed 3 times to authenticate with Intercom")
      end
    end

    context "when there's an intermittent authentication failure" do
      before do
        call_count = 0
        allow(fake_intercom.messages).to receive(:create).with(params) {
          call_count += 1
          if call_count <= 3
            raise Intercom::AuthenticationError.new("fake error")
          end
        }.exactly(4).times

        allow(DatadogApi).to receive(:increment).with("intercom.api.authentication_failure_retry").exactly(4).times
      end

      it "fails once but works the second time" do
        expect {
          described_class.intercom_api(:messages, :create, params)
        }.not_to raise_error

        expect(DatadogApi).to have_received(:increment).with("intercom.api.authentication_failure_retry").exactly(3).times
      end
    end
  end

  describe ".generate_user_hash" do
    it "generates a hash for a user ID" do
      expect(described_class.generate_user_hash("a-id-for-testing")).not_to be_nil
    end

    it "does nothing if no ID is provided" do
      expect(described_class.generate_user_hash(nil)).to be_nil
    end
  end
end
