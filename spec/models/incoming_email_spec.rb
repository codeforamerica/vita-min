# == Schema Information
#
# Table name: incoming_emails
#
#  id                 :bigint           not null, primary key
#  attachment_count   :integer
#  body_html          :string
#  body_plain         :string
#  from               :citext           not null
#  received           :string
#  received_at        :datetime         not null
#  recipient          :string           not null
#  sender             :string           not null
#  stripped_html      :string
#  stripped_signature :string
#  stripped_text      :string
#  subject            :string
#  to                 :citext
#  user_agent         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  client_id          :bigint           not null
#  message_id         :string
#
# Indexes
#
#  index_incoming_emails_on_client_id   (client_id)
#  index_incoming_emails_on_created_at  (created_at)
#
require 'rails_helper'

describe IncomingEmail do
  describe '#body' do
    context 'when stripped_text and stripped_signature are present' do
      let(:subject) do
        build(
          :incoming_email,
          stripped_text: "My name is Tax Person",
          stripped_signature: "Sincerely, Tax Person",
          body_plain: "My name is Tax Person\nSincerely, Tax Person\nA lot of other stuff we don't care about"
        )
      end

      it 'returns stripped_text and stripped_signature smashed together' do
        expect(subject.body).to eq("My name is Tax Person\nSincerely, Tax Person")
      end
    end

    context 'when stripped_text is present but stripped_signature is blank' do
      let(:subject) do
        build(
          :incoming_email,
          stripped_text: "My name is Tax Person",
          stripped_signature: '',
          body_plain: "My name is Tax Person\nA lot of other stuff we don't care about"
        )
      end

      it 'returns stripped_text' do
        expect(subject.body).to eq("My name is Tax Person")
      end
    end

    context 'when stripped_text is absent' do
      let(:subject) { build(:incoming_email, stripped_text: nil, stripped_signature: nil, body_plain: "I love sending emails to websites") }

      it 'returns body_plain' do
        expect(subject.body).to eq("I love sending emails to websites")
      end
    end
  end

  context "interaction tracking" do
    it_behaves_like "an incoming interaction" do
      let(:subject) { build(:incoming_email) }
    end
  end

  context 'enable_email_opt_in' do
    let(:intake) { create :intake, email_notification_opt_in: 'no' }
    let(:client) { intake.client }
    let(:subject) {
      build(
        :incoming_email,
        stripped_text: nil,
        stripped_signature: nil,
        body_plain: "I love sending emails to websites",
        client_id: client.id,
        to: 'hello@getyourrefund.org',
      )
    }

    it 'updates email_notification_opt_in to yes with correct incoming_email' do
      expect(intake.email_notification_opt_in).to eq('no')
      subject.save
      expect(intake.reload.email_notification_opt_in).to eq('yes')
    end
  end

  context 'enable_email_opt_in on demo' do
    let(:intake) { create :intake, email_notification_opt_in: 'no' }
    let(:client) { intake.client }
    let(:subject) {
      build(
        :incoming_email,
        stripped_text: nil,
        stripped_signature: nil,
        body_plain: "I love sending emails to websites",
        client_id: client.id,
        to: 'hello@mg-demo.getyourrefund-testing.org',
        )
    }
    before do
      allow(Rails).to receive(:env).and_return('demo')
    end

    it 'updates email_notification_opt_in to yes with correct incoming_email' do
      expect(intake.email_notification_opt_in).to eq('no')
      subject.save
      expect(intake.reload.email_notification_opt_in).to eq('yes')
    end
  end
end
