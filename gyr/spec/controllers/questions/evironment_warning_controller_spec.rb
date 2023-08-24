require "rails_helper"

RSpec.describe Questions::EnvironmentWarningController do
  describe ".show?" do
    let(:intake) { create :intake }
    context "when the environment is production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "returns false" do
        expect(Questions::EnvironmentWarningController.show?(intake)).to eq false
      end
    end

    context "when the environment is NOT production" do
      before do
        allow(Rails).to receive(:env).and_return("staging".inquiry)
      end

      it "returns true" do
        expect(Questions::EnvironmentWarningController.show?(intake)).to eq true
      end
    end
  end
end