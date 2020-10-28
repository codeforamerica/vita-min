require "rails_helper"

RSpec.describe Questions::EipOverviewController do
  render_views

  describe "#edit" do
    context "without an intake in the session" do
      it "renders successfully" do
        get :edit

        expect(response).to be_ok
      end
    end
  end

  describe "#update" do
    let(:valid_params) do
      {
        eip_overview_form: {
          eip_only: "true"
        }
      }
    end

    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

    it "creates an eip only intake" do
      expect {
        put :update, params: valid_params
      }.to change(Intake, :count).by(1)

      intake = Intake.last
      expect(intake.eip_only).to eq true
      expect(intake.client).to be_present
    end

    it "creates an intake with basic information" do
      expect {
        put :update, params: valid_params
      }.to change(Intake, :count).by(1)

      intake = Intake.last
      expect(intake.source).to eq "source_from_session"
      expect(intake.referrer).to eq "referrer_from_session"
      expect(intake.locale).to eq "en"
    end

    it "updates the intake in the session" do
      put :update, params: valid_params

      intake = Intake.last
      expect(session[:intake_id]).to eq intake.id
    end

    context "with an existing intake in the session" do
      let(:intake) { create :intake }
      before { session[:intake_id] = intake.id }

      it "replaces the existing intake with a new one in the session" do
        put :update, params: valid_params

        expect(session[:intake_id]).to be_present
        expect(session[:intake_id]).not_to eq intake.id
      end
    end

    context "with existing stimulus triage id in session" do
      let(:stimulus_triage) { create :stimulus_triage }
      before { session[:stimulus_triage_id] = stimulus_triage.id }

      it "links it to the new intake and deletes it from the session" do
        put :update, params: valid_params

        intake = Intake.last
        expect(intake.triage_source).to eq stimulus_triage
        expect(session[:stimulus_triage_id]).to be_nil
      end
    end
  end
end
