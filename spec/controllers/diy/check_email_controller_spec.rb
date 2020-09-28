require "rails_helper"

RSpec.describe Diy::CheckEmailController, type: :controller do

  describe "#edit" do
    let(:diy_intake) { create :diy_intake }

    before do
      session[:diy_intake_id] = diy_intake.id
    end

    it "clears the diy intake session" do
      get :edit

      expect(session[:diy_intake_id]).to be_nil
    end

    it "does not redirect on reload" do
      2.times do
        get :edit
      end

      expect(response.status).to eq 200
    end
  end
end