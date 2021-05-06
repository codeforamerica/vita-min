require "rails_helper"

RSpec.describe SendOutgoingEmailJob, type: :job do
  describe "#perform" do
    let(:outgoing_email) { create :outgoing_email }
    let(:mailer) { double(OutgoingEmailMailer) }
    let(:message_id) { "some_fake_id"}
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

    before do
      allow(OutgoingEmailMailer).to receive(:user_message).and_return(mailer)
      allow(mailer).to receive(:deliver_now).and_return Mail::Message.new(message_id: message_id)
    end

    it "sends the message using deliver_now and persists the message_id & sent_at" do
      Timecop.freeze(fake_time) { described_class.perform_now(outgoing_email.id) }
      expect(OutgoingEmailMailer).to have_received(:user_message).with(outgoing_email: outgoing_email)
      expect(outgoing_email.reload.message_id).to eq message_id
      expect(outgoing_email.sent_at).to eq fake_time
    end
  end
end
