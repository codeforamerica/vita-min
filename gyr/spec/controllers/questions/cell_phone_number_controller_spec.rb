require "rails_helper"

RSpec.describe Questions::CellPhoneNumberController do
  render_views

  let!(:intake) { create :intake, sms_phone_number: nil, sms_notification_opt_in: 'yes' }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          cell_phone_number_form: {
            sms_phone_number: "(415) 553-7865",
            sms_phone_number_confirmation: "(415) 553-7865",
          }
        }
      end

      it "sets the sms phone number on the intake" do
        expect do
          post :update, params: params
        end.to change { intake.reload.sms_phone_number }
          .from(nil)
          .to("+14155537865")
      end

      it "sends an event to mixpanel without the sms phone number data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "question_answered",
          data: {}
        ))
      end
    end

    context "with non-matching sms phone numbers" do
      let(:params) do
        {
          cell_phone_number_form: {
            sms_phone_number: "415-553-7865",
            sms_phone_number_confirmation: "415-553-1234",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params

        expect(response.body).to include("Please double check that the cell phone numbers match.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_sms_phone_number_confirmation: true
          }
        ))
      end
    end

    context "with an invalid sms phone number" do
      let(:params) do
        {
          cell_phone_number_form: {
            sms_phone_number: "555-555-123",
            sms_phone_number_confirmation: "555-555-123",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params

        expect(response.body).to include("Please enter a valid phone number.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_sms_phone_number: true
          },
          )
        )
      end
    end

    context "when the client opts into sms messages" do
      let(:params) do
        {
          cell_phone_number_form: {
            sms_phone_number: "415-555-1234",
            sms_phone_number_confirmation: "415-555-1234",
          }
        }
      end

      before do
        allow(ClientMessagingService).to receive(:send_system_text_message)
      end

      context "locale is english" do
        it "sends the client the opt-in sms message" do
          post :update, params: params

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            client: intake.client,
            body: I18n.t("messages.sms_opt_in", locale: "en")
          )
        end
      end

      context "locale is spanish" do
        it "sends the client the opt-in sms message in spanish" do
          post :update, params: params.merge(locale: "es")

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            client: intake.client,
            body: I18n.t("messages.sms_opt_in", locale: "es")
          )
        end
      end
    end
  end
end
