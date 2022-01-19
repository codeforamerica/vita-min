require "rails_helper"

RSpec.describe Questions::BacktaxesController do
  render_views

  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
      cookies[:visitor_id] = "some_visitor_id"
    end

    context "with valid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2018: "yes",
            needs_help_2019: "yes",
            needs_help_2020: "no",
            needs_help_2021: "yes"
          }
        }
      end

      context "without an intake in the session" do
        it "creates new intake with backtaxes answers and an associated client" do
          expect {
            post :update, params: params
          }.to change(Intake, :count).by(1)

          intake = Intake.last

          expect(intake.client).to be_present
          expect(intake.source).to eq "source_from_session"
          expect(intake.referrer).to eq "referrer_from_session"
          expect(intake.locale).to eq "en"
          expect(intake.needs_help_2018).to eq "yes"
          expect(intake.needs_help_2019).to eq "yes"
          expect(intake.needs_help_2021).to eq "yes"
          expect(intake.visitor_id).to eq "some_visitor_id"
        end
      end

      # TODO: should this check something about client? should it create a new client?
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
    end

    context "with invalid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2018: "no",
            needs_help_2019: "no",
            needs_help_2020: "no",
            needs_help_2021: "no"
          }
        }
      end

      it "renders edit with validation error" do
        post :update, params: params

        expect(response).to render_template(:edit)

        expect(response.body).to include "Please pick at least one year."
      end
    end
  end
end
