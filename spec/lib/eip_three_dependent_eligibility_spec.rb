require "rails_helper"

describe EipThreeDependentEligibility do
  describe ".eligible?" do
    let(:dependent_birthdate) { nil }
    let(:disabled) { nil }
    let(:student) { nil }
    let(:filer_birthdate) { nil }
    let(:params) {
      {
        dependent_birthdate: dependent_birthdate,
        disabled: disabled,
        student: student,
        filer_birthdate: filer_birthdate
      }
    }

    context "when the dependent is disabled" do
      let(:disabled) { true }

      it "should return TRUE" do
        expect(described_class.eligible?(params)).to eq true
      end
    end

    context "when the dependent is NOT disabled and WAS under nineteen at time of filing" do
      let(:disabled) { false }
      let(:dependent_birthdate) { Date.new(2003, 1, 1) }

      it "should return TRUE" do
        expect(described_class.eligible?(params)).to eq true
      end
    end

    context "when the dependent is NOT disabled, NOT under nineteen at time of filing, and NOT a student" do
      let(:disabled) { false }
      let(:dependent_birthdate) { Date.new(2001, 12, 31) }
      let(:student) { false }

      it "should return FALSE" do
        expect(described_class.eligible?(params)).to eq false
      end
    end

    context "when the dependent is NOT disabled, NOT under nineteen at time of filing, and IS a student" do
      let(:disabled) { false }
      let(:student) { true }

      context "when dependent was OVER twenty four at time of filing" do
        let(:dependent_birthdate) { Date.new(1996, 12, 31) }

        it "should return FALSE" do
          expect(described_class.eligible?(params)).to eq false
        end
      end

      context "when dependent was twenty four at time of filing, and is YOUNGER than the filer" do
        let(:dependent_birthdate) { Date.new(1997, 1, 1) }
        let(:filer_birthdate) { Date.new(1986, 11, 2) }

        it "should return TRUE" do
          expect(described_class.eligible?(params)).to eq true
        end
      end

      context "when dependent was UNDER twenty four at time of filing, and is YOUNGER than the filer" do
        let(:dependent_birthdate) { Date.new(1997, 1, 2) }
        let(:filer_birthdate) { Date.new(1986, 11, 2) }

        it "should return TRUE" do
          expect(described_class.eligible?(params)).to eq true
        end
      end

      context "when dependent was UNDER twenty four at time of filing, and is OLDER than the filer" do
        let(:dependent_birthdate) { Date.new(1997, 1, 2) }
        let(:filer_birthdate) { Date.new(1998, 1, 2) }

        it "should return FALSE" do
          expect(described_class.eligible?(params)).to eq false
        end
      end
    end
  end
end
