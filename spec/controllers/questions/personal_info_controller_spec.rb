require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:intake) { create :intake, source: "SourceParam" }
    let(:state) { 'CO' }
    let(:params) do
      {
        personal_info_form: {
          timezone: "America/New_York",
          zip_code: "80309",
          preferred_name: "Shep",
          phone_number: "+14156778899",
          phone_number_confirmation: "+14156778899",
        }
      }
    end

    before do
      allow(MixpanelService).to receive(:send_event)
    end

    it "sets the timezone on the intake" do
      expect { post :update, params: params }
        .to change { intake.timezone }.to("America/New_York")
    end

    it "sets preferred name, zip code and phone number" do
      expect { post :update, params: params }
        .to change { intake.preferred_name }.to("Shep").and change { intake.zip_code }.to("80309").and change { intake.phone_number }.to("+14156778899")
    end

    it "sends an event to mixpanel without PII" do
      post :update, params: params

      expect(MixpanelService)
        .to have_received(:send_event)
              .with(hash_including(
                      event_name: "question_answered",
                      data: hash_excluding(
                        :primary_ssn
                      )
                    ))
    end

    context "with invalid params" do
      let (:params) do
        {
          personal_info_form: {
            timezone: "America/New_York",
            zip_code: "80309",
            phone_number: "+14156778899",
            phone_number_confirmation: "+14156778899",
            preferred_name: nil,
            primary_last_name: nil,
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:preferred_name].first).to eq "Please enter your preferred name."
      end
    end
  end
end

