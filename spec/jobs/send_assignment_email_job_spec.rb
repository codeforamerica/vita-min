require "rails_helper"

RSpec.describe SendAssignmentEmailJob, type: :job do
  describe "#perform" do
    let(:assignment_email) { create :assignment_email }
    let(:mailer) { double(UserMailer) }
    let(:message_id) { "some_fake_id"}
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

    before do
      allow(UserMailer).to receive(:assignment_email).and_return(mailer)
      allow(mailer).to receive(:deliver_now).and_return Mail::Message.new(message_id: message_id)
    end

    it "sends the message using deliver_now and persists the message_id & sent_at" do
      Timecop.freeze(fake_time) { described_class.perform_now(assignment_email.id) }
      expect(UserMailer).to have_received(:assignment_email).with(assignment_email)
      expect(assignment_email.reload.message_id).to eq message_id
      expect(assignment_email.sent_at).to eq fake_time
    end
  end
end
