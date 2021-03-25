require "rails_helper"

RSpec.describe Questions::FinalInfoController do
  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
  end

  describe "#update" do
    let(:params) do
      { final_info_form: { final_info: "I moved here from Alaska." } }
    end

    before do
      sign_in intake.client
    end

    context "for any intake" do
      before do
        allow(IntakePdfJob).to receive(:perform_later)
      end

      let(:intake) { create :intake, sms_phone_number: "+15105551234", email_address: "someone@example.com" }
      let(:client) { intake.client }

      it "the model after_update when completed at changes should enqueue the creation of the 13614c document" do
        post :update, params: params

        expect(IntakePdfJob).to have_received(:perform_later).with(intake.id, "Original 13614-C.pdf")
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
              document_upload_url: "http://test.host/documents/add/#{intake.reload.requested_docs_token}"
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
              document_upload_url: "http://test.host/es/documents/add/#{intake.reload.requested_docs_token}"
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
              document_upload_url: "http://test.host/es/documents/add/#{intake.reload.requested_docs_token}"
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

      let(:intake) { create :intake }

      it "updates completed_at" do
        post :update, params: params

        expect(intake.reload.completed_at).to be_within(2.seconds).of(Time.now)
      end

      context "mixpanel" do
        let(:fake_tracker) { double('mixpanel tracker') }
        let(:fake_mixpanel_data) { {} }

        before do
          allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
          allow(MixpanelService).to receive(:send_event)
        end

        it "sends intake_finished event to Mixpanel" do
          post :update, params: params

          expect(MixpanelService).to have_received(:send_event).with(
            event_id: intake.visitor_id,
            event_name: "intake_finished",
            data: fake_mixpanel_data
          )

          expect(MixpanelService).to have_received(:data_from).with([intake.client, intake])
        end
      end
    end
  end
end
