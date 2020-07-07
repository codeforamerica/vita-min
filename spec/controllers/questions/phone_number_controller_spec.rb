require "rails_helper"

RSpec.describe Questions::PhoneNumberController do
  render_views

  let(:intake) { create :intake }

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
          phone_number_form: {
            phone_number: "(415) 553-7865",
            phone_number_confirmation: "(415) 553-7865",
            phone_number_can_receive_texts: "yes",
          }
        }
      end

      it "sets the phone number on the intake" do
        expect do
          post :update, params: params
        end.to change { intake.reload.phone_number }
          .from(nil)
          .to("14155537865")
      end

      it "sends an event to mixpanel without the phone number data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "question_answered",
          data: {}
        ))
      end
    end

    context "with non-matching phone numbers" do
      let(:params) do
        {
          phone_number_form: {
            phone_number: "415-553-7865",
            phone_number_confirmation: "415-553-1234",
            phone_number_can_receive_texts: "yes",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params

        expect(response.body).to include("Please double check that the phone numbers match.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_phone_number_confirmation: true
          }
        ))
      end
    end

    context "with an invalid phone number" do
      let(:params) do
        {
          phone_number_form: {
            phone_number: "555-555-123",
            phone_number_confirmation: "555-555-123",
            phone_number_can_receive_texts: "yes",
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
            invalid_phone_number: true
          },
          )
        )
      end
    end
  end
end
