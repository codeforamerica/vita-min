require "rails_helper"

describe ChildRelationshipQualifier do
  MOCK_QUALIFYING_RELATIONSHIPS = ["DAUGHTER", "SON"]

  describe ".qualifies?" do
    it "should return TRUE if a qualifying relationship is given" do
      qualifying_relationship = "DAUGHTER"
      qualifies = described_class.qualifies?(relationship: qualifying_relationship)

      expect(qualifies).to eq true
    end

    it "should return FALSE if a non-qualifying relationship is given" do
      non_qualifying_relationship = "NUTRITIONIST"
      qualifies = described_class.qualifies?(relationship: non_qualifying_relationship)

      expect(qualifies).to eq false
    end
  end
end
