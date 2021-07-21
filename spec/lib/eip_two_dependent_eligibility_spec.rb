require "rails_helper"

describe EipTwoDependentEligibility do
  describe ".eligible?" do
    let(:relationship) { nil }

    context "when a qualifying child relationship" do
      let(:relationship) { "DAUGHTER" }

      it "should return TRUE with a birthdate ON Jan 1 2004" do
        valid_birthdate = Date.new(2004, 1, 1)
        eligible = described_class.eligible?(birthdate: valid_birthdate, relationship: relationship)

        expect(eligible).to eq true
      end

      it "should return TRUE with a birthdate AFTER Jan 1 2004" do
        valid_birthdate = Date.new(2004, 1, 2)
        eligible = described_class.eligible?(birthdate: valid_birthdate, relationship: relationship)

        expect(eligible).to eq true
      end

      it "should return FALSE with a birthdate BEFORE Jan 1 2004" do
        invalid_birthdate = Date.new(2003, 12, 31)
        eligible = described_class.eligible?(birthdate: invalid_birthdate, relationship: relationship)

        expect(eligible).to eq false
      end
    end

    context "when a NON-qualifying child relationship" do
      let(:relationship) { "NUTRITIONIST" }

      it "should return FALSE regardless of birthdate" do
        valid_birthdate = Date.new(2004, 1, 2)
        eligible = described_class.eligible?(birthdate: valid_birthdate, relationship: relationship)

        expect(eligible).to eq false
      end
    end
  end
end
