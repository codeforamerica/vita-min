RSpec.describe IntercomService do
  let(:fake_intercom) { instance_double(Intercom::Client) }

  before do
    allow(Intercom::Client).to receive(:new).and_return(fake_intercom)
    allow(Rails.application.credentials).to receive(:intercom_access_token!).and_return("fake_access_token")
  end

  describe "#create_message_from_intercom" do
    context "when lead is found" do
      context "and conversation exists for the lead" do
        it "creates a message in the exisiting thread" do
          #expect intercom messages to receive create with message properties and return message id
        end
      end

      context "and no conversation exists for the lead" do
        it "creates a conversation" do

        end
      end
    end

    context "when no lead is found" do

    end
  end

  describe "#create_intercom_message_from_email" do
    context "no existing conversation with email" do
      let(:message_properties) do
        from : {
          type: "user",
          email:
        },
          body : body
      end
      it "creates a new a conversation" do
        expect(intercom.messages).to receive()
      end
    end
  end

  describe ".create_lead_by_email" do
    let(:contact_attr) do
      {
        email: "sqaush@example.com",
        name: "Sally Squash"
      }
    end

    it "creates a new lead with email and name" do
      subject.create_lead_by_email("")
      expect(fake_intercom.contacts).to have_received(:create).with(contact_attr)
    end
  end
end