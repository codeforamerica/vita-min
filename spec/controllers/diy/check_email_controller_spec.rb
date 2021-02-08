require "rails_helper"

RSpec.describe Diy::CheckEmailController, type: :controller do

  describe "#edit" do
    let(:diy_intake) { create :diy_intake }

    before do
      session[:diy_intake_id] = diy_intake.id
      allow(Rails.configuration).to receive(:diy_off).and_return false
      Rails.application.reload_routes!
    end

    after do
      allow(Rails.configuration).to receive(:diy_off).and_call_original
      Rails.application.reload_routes!
    end

    it "clears the diy intake session" do
      get :edit

      expect(session[:diy_intake_id]).to be_nil
    end
  end
end