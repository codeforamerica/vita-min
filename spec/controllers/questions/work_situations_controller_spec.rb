require "rails_helper"

RSpec.describe Questions::WorkSituationsController do
  describe ".show?" do
    context "with an intake that had jobs" do
      let!(:intake) { create :intake, job_count: "1" }

      it "returns true" do
        expect(Questions::WorkSituationsController.show?(intake)).to eq true
      end
    end

    context "with an intake that had no jobs" do
      let!(:intake) { create :intake, job_count: "0" }

      it "returns false" do
        expect(Questions::WorkSituationsController.show?(intake)).to eq false
      end
    end
  end
end

