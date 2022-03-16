require "rails_helper"

describe Efile::DependentEligibility::Base do
  let(:dependent) { create :dependent }
  subject { described_class.new(dependent, TaxReturn.current_tax_year) }

  context "without rules defined" do
    it "raises an error that you need rules" do
      expect {
        subject.qualifies?
      }.to raise_error RuntimeError, "Child classes must implement rules"
    end
  end

  context "with rules defined" do
    before do
      allow(described_class).to receive(:rules).and_return (
                                                                                      {
                                                                                          true_rule: :present?,
                                                                                          complex_true_rule: [:present?, :present?],
                                                                                          false_rule: [:nil?, :nil?],
                                                                                          second_false_rule: [:nil?]
                                                                                      }
                                                                                  )
    end

    describe ".age" do
      let(:dependent) { create :qualifying_child, birth_date: birth_date }

      context "when born on Jan 1 of the tax year" do
        let(:birth_date) { Date.new(TaxReturn.current_tax_year, 1, 1) }

        it "is 0" do
          expect(subject.age).to eq(0)
        end
      end

      context "when born on Dec 31 of the previous year" do
        let(:birth_date) { Date.new(TaxReturn.current_tax_year - 1, 12, 31) }

        it "is 1" do
          expect(subject.age).to eq(1)
        end
      end
    end

    describe ".disqualifiers" do
      it "returns a list of rules that return false" do
        expect(subject.disqualifiers).to eq [:false_rule, :second_false_rule]
      end

      context "with except" do
        subject { described_class.new(dependent, TaxReturn.current_tax_year, except: :second_false_rule) }
        it "does not consider the rules that are sent in the only param" do
          expect(subject.disqualifiers).to eq [:false_rule]
        end
      end
    end

    describe ".qualifies?" do
      context "with some of the rules (where some return false" do
        it "returns false" do
          expect(subject.qualifies?).to eq false
        end
      end

      context "when except excluding with rules that return false" do
        subject { described_class.new(dependent, TaxReturn.current_tax_year, except: [:second_false_rule, :false_rule]) }
        it "returns true" do
          expect(subject.qualifies?).to eq true
        end
      end
    end

  end
end