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
            needs_help_2017: "no",
            needs_help_2018: "yes",
            needs_help_2019: "yes",
            needs_help_2020: "no",
          }
        }
      end

      context "without an intake in the session" do
        it "creates new intake backtaxes answers" do
          expect {
            post :update, params: params
          }.to change(Intake, :count).by(1)

          intake = Intake.last

          expect(intake.client).to be_present
          expect(intake.source).to eq "source_from_session"
          expect(intake.referrer).to eq "referrer_from_session"
          expect(intake.locale).to eq "en"
          expect(intake.needs_help_2017).to eq "no"
          expect(intake.needs_help_2018).to eq "yes"
          expect(intake.needs_help_2019).to eq "yes"
          expect(intake.visitor_id).to eq "some_visitor_id"
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

        it 'sets the navigator on the client' do
          post :update, params: params

          intake = Intake.last

          expect(intake.with_unhoused_navigator?).to be_truthy
        end
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2017: "no",
            needs_help_2018: "no",
            needs_help_2019: "no",
            needs_help_2020: "no",
          }
        }
      end

      it "renders edit with validation error" do
        post :update, params: params

        expect(response).to render_template(:edit)

        expect(response.body).to include "Please pick at least one year."
      end
    end

    context "with a triage source" do
      let(:stimulus_triage) { create :stimulus_triage }
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2017: "yes",
            needs_help_2018: "no",
            needs_help_2019: "no",
            needs_help_2020: "no",
          }
        }
      end

      it "assigns the triage source to the intake" do
        session[:triage_source_id] = stimulus_triage.id
        session[:triage_source_type] = stimulus_triage.class.to_s

        post :update, params: params

        intake = Intake.find(session[:intake_id])

        expect(intake.triage_source_id).to eq(stimulus_triage.id)
        expect(intake.triage_source_type).to eq(stimulus_triage.class.to_s)
      end
    end
  end

  describe "#edit" do
    context "with a triage source" do
      let(:stimulus_triage) { create :stimulus_triage }

      it "captures the triage source's type and id" do
        session[:stimulus_triage_id] = stimulus_triage.id

        get :edit

        expect(session[:triage_source_id]).to eq(stimulus_triage.id)
        expect(session[:triage_source_type]).to eq(stimulus_triage.class.to_s)
        expect(session.has_key?(:stimulus_triage_id)).to be_falsey
      end
    end
  end
end
