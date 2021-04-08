require "rails_helper"

RSpec.describe SendOutgoingEmailJob, type: :job do
  describe "#perform" do
    let(:outgoing_email) { create :outgoing_email }
    let(:mailer) { double(OutgoingEmailMailer) }
    let(:message_id) { "some_fake_id"}
    before do
      allow(OutgoingEmailMailer).to receive(:user_message).and_return(mailer)
      allow(mailer).to receive(:deliver_now).and_return Mail::Message.new(message_id: message_id)
    end

    it "sends the message using deliver_now and persists the message_id and default status to the object" do
      described_class.perform_now(outgoing_email.id)
      expect(OutgoingEmailMailer).to have_received(:user_message).with(outgoing_email: outgoing_email)
      expect(outgoing_email.reload.message_id).to eq message_id
      expect(outgoing_email.reload.mailgun_status).to eq "sending"
    end
  end
end
