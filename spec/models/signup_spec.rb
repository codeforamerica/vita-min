# == Schema Information
#
# Table name: signups
#
#  id                               :bigint           not null, primary key
#  ctc_2022_open_message_sent_at    :datetime
#  email_address                    :citext
#  name                             :string
#  phone_number                     :string
#  puerto_rico_open_message_sent_at :datetime
#  zip_code                         :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
require "rails_helper"

RSpec.describe Signup, type: :model do
  describe "validations" do
    context "with valid fields" do
      context "with name & phone" do
        let(:signup) { Signup.new(name: "Gary Guava", phone_number: "+14155551212") }

        it "is valid" do
          expect(signup).to be_valid
        end
      end

      context "with name & email" do
        let(:signup) { Signup.new(name: "Gary Guava", email_address: "example@example.com") }

        it "is valid" do
          expect(signup).to be_valid
        end
      end
    end

    context "with invalid fields" do
      context "invalid zipcode" do
        let(:signup) { Signup.new(name: "Gary Guava", email_address: "example@example.com", zip_code: "1234") }

        it "is not valid and adds an error to the zipcode" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :zip_code
          expect(signup.errors[:zip_code]).to eq(["Please enter a valid 5-digit zip code."])
        end
      end

      context "without any fields" do
        let(:signup) { Signup.new }

        it "requires a name" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :name
        end
      end

      context "without email or phone number fields" do
        let(:signup) { Signup.new(name: "Gary Guava") }

        it "is not valid and adds an error to the phone number" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :email_address
          expect(signup.errors).not_to include :phone_number
          expect(signup.errors[:email_address]).to eq(["Please choose some way for us to contact you."])
        end
      end

      context "with an invalid phone number" do
        let(:signup) { build(:signup, phone_number: "5123456789") }

        it "is not valid and adds an error to the phone number" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :phone_number
        end
      end

      context "with an invalid email" do
        let(:signup) { build(:signup, email_address: "someone@example .com") }

        it "is not valid and adds an error to the email" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :email_address
        end
      end
    end
  end

  describe ".send_message" do
    subject { described_class.send_message("ctc_2022_open_message") }
    context "when an email is present" do
      let!(:signup) { create :signup, email_address: "mango@example.com" }

      it "sends an email and updates the timestamp" do
        expect {
          subject
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.body.encoded).to include AutomatedMessage::Ctc2022OpenMessage.new.email_body[0..20]
        expect(mail.to).to eq ["mango@example.com"]
        expect(mail.subject).to eq AutomatedMessage::Ctc2022OpenMessage.new.email_subject
        expect(mail.from).to eq ["no-reply@ctc.test.localhost"]
        expect(signup.reload.ctc_2022_open_message_sent_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context "when a phone number is present" do
      let(:twilio_service) { instance_double TwilioService }
      let!(:signup) { create :signup, phone_number: "+18888888888" }
      before do
        allow(TwilioService).to receive(:new).and_return twilio_service
        allow(twilio_service).to receive(:send_text_message)
      end
      it "sends a text message" do
        subject
        expect(twilio_service).to have_received(:send_text_message).with(to: "+18888888888", body: AutomatedMessage::Ctc2022OpenMessage.new.sms_body)
        expect(signup.reload.ctc_2022_open_message_sent_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    context "when an after attribute is present" do
      let(:signup_double) { double Signup }

      context 'building the query' do
        before do
          allow(Signup).to receive(:where).and_return signup_double
          allow(signup_double).to receive(:find_each)
        end

        it "uses the after value to create the query" do
          Signup.send_message("ctc_2022_open_message", after: Date.today.beginning_of_day)
          expect(Signup).to have_received(:where).with("created_at >= ?", Date.today.beginning_of_day)
        end
      end

      context 'segmenting the signups' do
        let!(:excluded_signup) { create :signup, created_at: 2.years.ago }
        let!(:included_signup) { create :signup, created_at: 1.year.ago.beginning_of_day }

        it "sends to the included signup but not to the not included signup" do
          Signup.send_message("puerto_rico_open_message", after: 1.year.ago.beginning_of_day)
          expect(included_signup.reload.puerto_rico_open_message_sent_at).to be_present
          expect(excluded_signup.reload.puerto_rico_open_message_sent_at).not_to be_present
        end
      end
    end
  end
end
