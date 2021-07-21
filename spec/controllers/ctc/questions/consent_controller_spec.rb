require "rails_helper"

describe Ctc::Questions::ConsentController do

  before do
    cookies[:visitor_id] = "visitor-id"
    session[:source] = "some-source"
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::ConsentForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end

    it "initializes the current intake with a visitor id and source" do
      expect {
        get :edit, params: {}
      }.to change(Intake, :count).by(1)
      intake = Intake.last
      expect(intake.visitor_id).to eq("visitor-id")
      expect(intake.source).to eq("some-source")
    end
  end
end