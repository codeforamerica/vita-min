require "rails_helper"

RSpec.describe Ctc::Questions::NoDependentsAdvanceCtcPaymentsController do
  describe ".show?" do
    let!(:intake) { create :ctc_intake }

    before do
      create :ctc_tax_return, client: intake.client
    end

    context "with an intake that has created dependents" do
      before do
        create :qualifying_child, intake: intake
      end

      it "returns false" do
        expect(Ctc::Questions::NoDependentsAdvanceCtcPaymentsController.show?(intake)).to eq false
      end
    end

    context "with an intake with no created dependents" do
      it "returns true" do
        expect(Ctc::Questions::NoDependentsAdvanceCtcPaymentsController.show?(intake)).to eq true
      end
    end

    context "with an intake with dependents but no qualifying dependents" do
      before do
        create :nonqualifying_dependent, intake: intake
      end

      it "returns true" do
        expect(Ctc::Questions::NoDependentsAdvanceCtcPaymentsController.show?(intake)).to eq true
      end
    end
  end
end
