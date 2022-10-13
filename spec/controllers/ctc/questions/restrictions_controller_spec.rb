require 'rails_helper'

describe Ctc::Questions::RestrictionsController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
  end

  describe "#edit" do
    before do
      allow(subject).to receive(:track_first_visit)
    end

    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end

    it "tracks the first visit to this page" do
      get :edit, params: {}
      expect(subject).to have_received(:track_first_visit).with(:ctc_restrictions)
    end
  end
end
