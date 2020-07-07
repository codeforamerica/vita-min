require "rails_helper"

RSpec.describe Stimulus::NeedToFileController do
  describe "#edit" do
    it "redirects to filed recently if no stimulus triage id in session" do
      session[:stimulus_triage_id] = nil
      get :edit

      expect(response).to redirect_to(stimulus_filed_recently_path)
    end
  end

  describe ".show?" do
    let(:stimulus_triage) { create(:stimulus_triage, filed_recently: filed_recently) }

    context "when client has filed recently" do
      let(:filed_recently) { "yes" }
      it "returns false" do
        expect(subject.class.show?(stimulus_triage)).to eq(false)
      end
    end

    context "when client has not filed recently" do
      let(:filed_recently) { "no" }
      it "returns true" do
        expect(subject.class.show?(stimulus_triage)).to eq(true)
      end
    end
  end
end
