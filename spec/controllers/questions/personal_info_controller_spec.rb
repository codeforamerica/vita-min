require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  describe "#update" do
    before do
      allow(MixpanelService).to receive(:send_event)
    end

    context "with valid params" do
      let(:params) do
        {
          personal_info_form: {
            timezone: "America/New_York",
            zip_code: "80309",
            preferred_name: "Shep",
            birth_date_year: "1983",
            birth_date_month: "3",
            birth_date_day: "12",
            phone_number: "+14156778899",
            phone_number_confirmation: "+14156778899",
          }
        }
      end

      let!(:organization_router) { double }

      before do
        session[:source] = "source_from_session"
        session[:referrer] = "referrer_from_session"
        cookies.encrypted[:visitor_id] = "some_visitor_id"
        allow(PartnerRoutingService).to receive(:new).and_return organization_router
        allow(organization_router).to receive(:determine_partner).and_return nil
        allow(organization_router).to receive(:routing_method).and_return :zip_code
      end

      context "with correct params and not at capacity" do
        it "directs to ssn page" do
          post :update, params: params
          expect(response).to redirect_to Questions::SsnItinController.to_path_helper
        end
      end

      context "without an intake in the session" do
        it "creates new intake and associated client" do
          expect {
            post :update, params: params
          }.to change(Intake, :count).by(1)

          intake = Intake.last

          expect(intake.client).to be_present
          expect(intake.source).to eq "source_from_session"
          expect(intake.referrer).to eq "referrer_from_session"
          expect(intake.locale).to eq "en"
          expect(intake.visitor_id).to eq "some_visitor_id"
          expect(intake.timezone).to eq "America/New_York"
          expect(intake.preferred_name).to eq "Shep"
          expect(intake.primary_birth_date).to eq Date.parse("1983-3-12")
          expect(intake.zip_code).to eq "80309"
          expect(intake.phone_number).to eq "+14156778899"
        end
      end

      context "with an existing intake in the session" do
        let(:intake) { create :intake }

        before { session[:intake_id] = intake.id }

        it "creates a new intake and overwrites the one in the session" do
          expect {
            post :update, params: params
          }.to change(Intake, :count).by(1)

          created_intake = Intake.last
          expect(session[:intake_id]).to eq created_intake.id
        end
      end

      context "with a navigator in the session" do
        before do
          session[:navigator] = "4"
        end

        it "sets the navigator on the client" do
          post :update, params: params

          intake = Intake.last

          expect(intake.with_unhoused_navigator?).to be_truthy
        end
      end

      context "routing the client when routing service returns nil and routing_method is at_capacity" do
        let!(:organization_router) { double }

        before do
          allow(PartnerRoutingService).to receive(:new).and_return organization_router
          allow(organization_router).to receive(:determine_partner).and_return nil
          allow(organization_router).to receive(:routing_method).and_return :at_capacity
        end

        it "saves routing method to at capacity, does not set a vita partner, does not create tax returns" do
          post :update, params: params

          intake = Intake.last
          expect(intake.client.routing_method).to eq("at_capacity")
          expect(intake.client.vita_partner).to eq nil
          expect(PartnerRoutingService).to have_received(:new).with(
            {
              intake: intake,
              source_param: intake.source,
              zip_code: "80309"
            }
          )
          expect(organization_router).to have_received(:determine_partner)
          expect(intake.tax_returns.count).to eq 0
          expect(response).to redirect_to Questions::AtCapacityController.to_path_helper
        end
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
    end

    context "with invalid params" do
      let(:params) do
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
