require "rails_helper"

RSpec.describe Questions::SsnItinsController do
  describe ".show?" do
    let(:intake) { create :intake }

    context "when they have dependents" do
      before { create :dependent, intake: intake }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they do not have dependents" do
      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

