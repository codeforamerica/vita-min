require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  let(:vita_partner) { create :organization }
  let(:organization_router) { double }
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
          primary_ssn: "123455678",
          primary_ssn_confirmation: "123455678",
          primary_tin_type: "ssn_no_employment"
        }
      }
    end

    before do
      allow(PartnerRoutingService).to receive(:new).and_return organization_router
      allow(organization_router).to receive(:determine_partner).and_return vita_partner
      allow(organization_router).to receive(:routing_method).and_return :source_param
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
            preferred_name: "Shep",
            phone_number: "+14156778899",
            phone_number_confirmation: "+14156778899",
            preferred_name: "Grindelwald",
            primary_last_name: nil,
            primary_ssn: nil
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:primary_ssn].first).to eq "An SSN or ITIN is required."
        expect(error_messages[:primary_tin_type].first).to eq "Identification type is required."
      end
    end
  end
end

