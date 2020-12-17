require "rails_helper"

RSpec.describe Questions::FinalInfoController do
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:params) do
      { final_info_form: { final_info: "I moved here from Alaska." } }
    end

    context "for any intake" do
      before do
        example_pdf = Tempfile.new("example.pdf")
        example_pdf.write("example pdf contents")
        allow(intake).to receive(:pdf).and_return(example_pdf)
        allow(intake).to receive(:create_original_13614c_document)
      end

      let(:intake) { create :intake, intake_ticket_id: 1234, sms_phone_number: "+15105551234", email_address: "someone@example.com" }
      let(:client) { intake.client }

      it "should trigger the creation of the 13614c document" do
        post :update, params: params
        expect(intake).to have_received(:create_original_13614c_document)
      end

      context "client is opted into emails" do
        before do
          intake.update(email_notification_opt_in: "yes")
        end

        it "sends a success email" do
          expect do
            post :update, params: params
          end.to change(OutgoingEmail, :count).by(1).and change(OutgoingTextMessage, :count).by(0)

          expect(OutgoingEmail.last.body).to eq I18n.t(
              "messages.successful_submission.email_body",
              locale: "en",
              preferred_name: intake.preferred_name,
              client_id: intake.client_id,
              document_upload_url: "http://test.host/documents/add/#{intake.requested_docs_token}"
          )
        end

        it "sends a success email in the correct language" do
          intake.update(locale: "es")
          post :update, params: params

          expect(OutgoingEmail.last.body).to eq I18n.t(
              "messages.successful_submission.email_body",
              locale: "es",
              preferred_name: intake.preferred_name,
              client_id: intake.client_id,
              document_upload_url: "http://test.host/es/documents/add/#{intake.requested_docs_token}"
          )
        end
      end

      context "client is opted into sms" do
        before do
          intake.update(sms_notification_opt_in: "yes")
        end

        it "sends a success sms" do
          expect do
            post :update, params: params
          end.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(0)
        end

        it "sends a success sms in the correct language" do
          intake.update(locale: "es")
          post :update, params: params

          expect(OutgoingTextMessage.last.body).to eq I18n.t(
              "messages.successful_submission.sms_body",
              locale: "es",
              preferred_name: intake.preferred_name,
              client_id: intake.client_id,
              document_upload_url: "http://test.host/es/documents/add/#{intake.requested_docs_token}"
          )
        end
      end

      context "client is opted into sms and email" do
        before do
          intake.update(sms_notification_opt_in: "yes", email_notification_opt_in: "yes")
        end

        it "sends a success sms and email" do
          expect do
            post :update, params: params
          end.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(1)
        end
      end
    end

    context "for a full intake" do
      before do
        example_pdf = Tempfile.new("example.pdf")
        example_pdf.write("example pdf contents")
        allow(intake).to receive(:pdf).and_return(example_pdf)
      end

      let(:intake) { create :intake, intake_ticket_id: 1234 }

      it "updates completed_intake_at" do
        post :update, params: params

        expect(intake.completed_at).to be_within(2.seconds).of(Time.now)
      end
    end
  end
end
