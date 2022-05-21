require "rails_helper"

RSpec.describe Ctc::Questions::NoDependentsController do
  describe ".show?" do
    let!(:intake) { create :ctc_intake }

    context "with an intake that has created dependents" do
      before do
        create :dependent, intake: intake
      end

      it "returns false" do
        expect(Ctc::Questions::NoDependentsController.show?(intake)).to eq false
      end
    end

    context "with an intake with no created dependents" do
      it "returns true" do
        expect(Ctc::Questions::NoDependentsController.show?(intake)).to eq true
      end
    end
  end
end
