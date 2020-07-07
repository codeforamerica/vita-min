require "rails_helper"

RSpec.describe Stimulus::FiledRecentlyController do
  describe "#edit" do
    let(:stimulus_triage) { create(:stimulus_triage) }

    before do
      allow(subject).to receive(:current_stimulus_triage).and_return(stimulus_triage)
    end

    it "sets a new visitor_id on the stimulus triage" do
      get :edit

      expect(stimulus_triage.visitor_id).to be_present
    end
  end

  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

    context "with valid params" do
      let(:params) do
        {
          "stimulus_filed_recently_form": {
            filed_recently: "yes"
          }
        }
      end

      it "creates new stimulus triage with source and referrer" do
        expect {
          post :update, params: params
        }.to change(StimulusTriage, :count).by(1)

        stimulus_triage = StimulusTriage.last
        expect(stimulus_triage.source).to eq "source_from_session"
        expect(stimulus_triage.referrer).to eq "referrer_from_session"
        expect(stimulus_triage).to be_filed_recently_yes
      end

      it "stores the stimulus triage id in the session" do
        expect {
          post :update, params: params
        }.to change { session[:stimulus_triage_id] }.from(nil)
        expect(session[:stimulus_triage_id]).to eq(StimulusTriage.last.id)
      end

      it "replaces the stimulus triage id in the session" do
        session[:stimulus_triage_id] = create(:stimulus_triage).id
        expect {
          post :update, params: params
        }.to change { session[:stimulus_triage_id] }
        expect(session[:stimulus_triage_id]).to eq(StimulusTriage.last.id)
      end
    end
  end
end
