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
            phone_number: "+14156778899",
            phone_number_confirmation: "+14156778899",
            need_itin_help: "no",
          }
        }
      end

      before do
        session[:source] = "source_from_session"
        session[:referrer] = "referrer_from_session"
        cookies[:visitor_id] = "some_visitor_id"
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
          expect(intake.zip_code).to eq "80309"
          expect(intake.phone_number).to eq "+14156778899"
          expect(intake.need_itin_help).to eq "no"
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

      context "with a triage in the session" do
        let(:triage) { create :triage }

        before do
          session[:triage_id] = triage.id
        end

        it "associates the triage with the intake" do
          post :update, params: params

          intake = Intake.last
          expect(intake.triage).to eq triage
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

