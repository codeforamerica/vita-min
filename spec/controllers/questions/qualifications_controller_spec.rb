require "rails_helper"

RSpec.describe Questions::QualificationsController do
  describe ".show?" do
    let!(:intake) { create :intake }

    it "returns true" do
      expect(Questions::QualificationsController.show?(intake)).to eq true
    end
  end

  describe "#edit" do
    before do
      allow(controller).to receive(:open_for_gyr_intake?).and_return(open_for_gyr)
    end

    context "when app if open for GYR" do
      let(:open_for_gyr) { true }

      it "is 200 OK 👍" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "when app is closed for GYR" do
      let(:open_for_gyr) { false }

      it "redirects to the root path" do
        get :edit

        expect(response).to redirect_to(root_path)
      end
    end
  end
end

