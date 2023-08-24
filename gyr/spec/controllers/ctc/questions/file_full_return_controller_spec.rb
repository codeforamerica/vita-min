require "rails_helper"

describe Ctc::Questions::FileFullReturnController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end
  end
end
