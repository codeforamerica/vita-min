require "rails_helper"

RSpec.describe Questions::ReceivedAlimonyController do
  describe ".show?" do
    context "with an intake that was ever married" do
      let!(:intake) { create :intake, ever_married: "yes" }

      it "returns true" do
        expect(Questions::ReceivedAlimonyController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not answered whether they were married" do
      let!(:intake) { create :intake, ever_married: "unfilled" }

      it "returns false" do
        expect(Questions::ReceivedAlimonyController.show?(intake)).to eq false
      end
    end

    context "with an intake that was never married" do
      let!(:intake) { create :intake, ever_married: "no" }

      it "returns false" do
        expect(Questions::ReceivedAlimonyController.show?(intake)).to eq false
      end
    end
  end
end

