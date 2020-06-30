require "rails_helper"

RSpec.describe Questions::BacktaxesController do
  render_views

  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

    context "with valid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2016: "no",
            needs_help_2017: "yes",
            needs_help_2018: "yes",
            needs_help_2019: "yes",
          }
        }
      end

      it "creates new intake backtaxes answers" do
        expect {
          post :update, params: params
        }.to change(Intake, :count).by(1)

        intake = Intake.last

        expect(intake.source).to eq "source_from_session"
        expect(intake.referrer).to eq "referrer_from_session"
        expect(intake.locale).to eq "en"
        expect(intake.needs_help_2016).to eq "no"
        expect(intake.needs_help_2017).to eq "yes"
        expect(intake.needs_help_2018).to eq "yes"
        expect(intake.needs_help_2019).to eq "yes"
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2016: "no",
            needs_help_2017: "no",
            needs_help_2018: "no",
            needs_help_2019: "no",
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
                needs_help_2016: "yes",
                needs_help_2017: "no",
                needs_help_2018: "no",
                needs_help_2019: "no",
            }
        }
      end

      fit "assigns the triage source to the intake" do
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

      fit "captures the triage source's type and id" do
        session[:stimulus_triage_id] = stimulus_triage.id

        get :edit

        expect(session[:triage_source_id]).to eq(stimulus_triage.id)
        expect(session[:triage_source_type]).to eq(stimulus_triage.class.to_s)
      end
    end
  end
end
