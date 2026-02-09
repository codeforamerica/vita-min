require "rails_helper"

RSpec.describe Diy::DiyCellPhoneNumberController do
  render_views

  let!(:diy_intake) { create :diy_intake, email_address: 'test@test.test', sms_phone_number: nil, sms_notification_opt_in: 'yes' }

  before do
    allow(subject).to receive(:current_diy_intake).and_return(diy_intake)
    allow(MixpanelService).to receive(:send_event)
  end

  describe ".show?" do
    context "when they do not have an sms phone number and opted in to texting" do
      it "returns true" do
        expect(described_class.show?(diy_intake)).to eq true
      end
    end

    context "when they have an sms phone number" do
      let!(:diy_intake) { create :diy_intake, email_address: 'test@test.test', sms_notification_opt_in: "yes", sms_phone_number: "+14155551212" }
      it "returns false" do
        expect(described_class.show?(diy_intake)).to eq false
      end
    end

    context "when they have not opted in to texting" do
      let!(:diy_intake) { create :diy_intake, email_address: 'test@test.test', sms_notification_opt_in: "no" }
      it "returns false" do
        expect(described_class.show?(diy_intake)).to eq false
      end
    end
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit, session: { diy_intake_id: diy_intake.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          diy_cell_phone_number_form: {
            sms_phone_number: "(415) 553-7865",
            sms_phone_number_confirmation: "(415) 553-7865",
          }
        }
      end

      it "sets the sms phone number on the diy_intake" do
        expect do
          post :update, params: params, session: { diy_intake_id: diy_intake.id }
        end.to change { diy_intake.reload.sms_phone_number }
          .from(nil)
          .to("+14155537865")
      end

      it "sends an event to mixpanel without the sms phone number data" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "form_submission",
          data: {}
        ))
      end
    end

    context "with non-matching sms phone numbers" do
      let(:params) do
        {
          diy_cell_phone_number_form: {
            sms_phone_number: "415-553-7865",
            sms_phone_number_confirmation: "415-553-1234",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(response.body).to include("Please double check that the cell phone numbers match.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

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
          diy_cell_phone_number_form: {
            sms_phone_number: "555-555-123",
            sms_phone_number_confirmation: "555-555-123",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

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
          diy_cell_phone_number_form: {
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
          post :update, params: params, session: { diy_intake_id: diy_intake.id }

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            client: diy_intake.client,
            body: I18n.t("messages.sms_opt_in", locale: "en")
          )
        end
      end

      context "locale is spanish" do
        it "sends the client the opt-in sms message in spanish" do
          post :update, params: params.merge(locale: "es"), session: { diy_intake_id: diy_intake.id }

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            client: diy_intake.client,
            body: I18n.t("messages.sms_opt_in", locale: "es")
          )
        end
      end
    end
  end
end

