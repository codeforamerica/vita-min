require 'rails_helper'

describe SendDiySupportEmailJob do
  let(:diy_intake) { create(:diy_intake, :filled_out) }
  let(:mailer) { double(DiyIntakeEmailMailer) }
  let(:message_id) { "some_fake_id"}
  let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

  before do
    allow(DiyIntakeEmailMailer).to receive(:message).and_return(mailer)
    allow(mailer).to receive(:deliver_now).and_return Mail::Message.new(message_id: message_id)
  end

  it 'sends an email' do
    Timecop.freeze(fake_time) { described_class.perform_now(diy_intake) }
    diy_intake_email = DiyIntakeEmail.last
    expect(DiyIntakeEmailMailer).to have_received(:message).with(diy_intake_email: diy_intake_email)
    expect(diy_intake_email.reload.message_id).to eq message_id
    expect(diy_intake_email.sent_at).to eq fake_time
  end
end
