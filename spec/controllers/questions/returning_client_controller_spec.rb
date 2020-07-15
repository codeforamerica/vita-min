require "rails_helper"

RSpec.describe Questions::ReturningClientController do
  let(:intake) { create :intake }
  let(:duplicate_intake_guard_spy) { instance_double(DuplicateIntakeGuard) }

  describe ".show?" do
    before do
      allow(DuplicateIntakeGuard).to receive(:new).with(intake).and_return duplicate_intake_guard_spy
    end

    context "when intake has duplicate" do
      before do
        allow(duplicate_intake_guard_spy).to receive(:has_duplicate?).and_return true
      end

      it { expect(subject.class.show?(intake)).to eq true }
    end

    context "when intake has no duplicate" do
      before do
        allow(duplicate_intake_guard_spy).to receive(:has_duplicate?).and_return false
      end

      it { expect(subject.class.show?(intake)).to eq false }
    end
  end
end
