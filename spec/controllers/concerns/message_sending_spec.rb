require "rails_helper"

RSpec.describe MessageSending, type: :controller do
  let(:intake) { create :intake, email_address: "client@example.com", sms_phone_number: "+14155551212"}
  let!(:client) { intake.client }
  let!(:user) { create :user }
  let(:expected_time) { DateTime.new(2020, 9, 9) }

  controller(ApplicationController) do
    include MessageSending
  end

  before do
    allow(DateTime).to receive(:now).and_return(expected_time)
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  describe "#send_email", active_job: true do
    context "without an authenticated user" do
      it "raises an error" do
        expect do
          subject.send_email(client, body: "hello")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with an authenticated user" do
      before { sign_in user }

      it "saves a new outgoing email with the right info, enqueues email, and broadcasts to ClientChannel" do
        expect do
          subject.send_email(client, body: "hello")
        end.to change(OutgoingEmail, :count).by(1).and have_enqueued_mail(OutgoingEmailMailer, :user_message)

        outgoing_email = OutgoingEmail.last
        expect(outgoing_email.subject).to eq("Update from GetYourRefund")
        expect(outgoing_email.body).to eq("hello")
        expect(outgoing_email.client).to eq client
        expect(outgoing_email.user).to eq user
        expect(outgoing_email.sent_at).to eq expected_time
        expect(outgoing_email.to).to eq client.email_address
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
      end

      context "with blank body" do
        it "raises an error" do
          expect do
            subject.send_email(client, body: " \n")
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "with an attachment" do
        let(:attachment) { fixture_file_upload("attachments/test-pattern.png") }

        it "saves the attachment" do
          subject.send_email(client, body: "hello", attachment: attachment)

          expect(OutgoingEmail.last.attachment).to be_present
        end
      end

      context "with a custom subject locale" do
        it "uses that locale" do
          subject.send_email(client, body: "hola", subject_locale: "es")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end

      context "with a client whose locale differs from the current request" do
        before { intake.update(locale: "es") }

        it "uses the client locale" do
          subject.send_email(client, body: "hola")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end
    end
  end

  describe "#send_text_message", active_job: true do
    context "without an authenticated user" do
      it "raises an error" do
        expect do
          subject.send_text_message(client, body: "hello")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with an authenticated user" do
      before { sign_in user }

      it "saves a new outgoing text message with the right info, enqueues job, and broadcasts to ClientChannel" do
        expect do
          subject.send_text_message(client, body: "hello")
        end.to change(OutgoingTextMessage, :count).by(1)

        outgoing_text_message = OutgoingTextMessage.last
        expect(outgoing_text_message.body).to eq("hello")
        expect(outgoing_text_message.client).to eq client
        expect(outgoing_text_message.user).to eq user
        expect(outgoing_text_message.sent_at).to eq expected_time
        expect(outgoing_text_message.to_phone_number).to eq client.sms_phone_number
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_text_message)
        expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
      end

      context "with blank body" do
        it "raises an error" do
          expect do
            subject.send_text_message(client, body: " \n")
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end