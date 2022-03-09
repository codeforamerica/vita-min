require "rails_helper"

describe Efile::Relationships do
  context 'initialization' do
    context "when it is a relationship that is not defined in the yaml file" do
      it "raises an error" do
        expect {
          described_class.new("next-door neighbor")
        }.to raise_error StandardError, "Relationship not defined"
      end
    end
  end

  describe "#irs_enum" do
    it "retrieves the defined IRS enum for the relationship value" do
      expect(described_class.new("in_law").irs_enum).to eq "OTHER"
      expect(described_class.new("daughter").irs_enum).to eq "DAUGHTER"
    end
  end

  describe "#qualifying_child_relationship?" do
    context "when the value in the yaml file for the relationship is qualified_child" do
      it "is true" do
        expect(described_class.new("daughter").qualifying_child_relationship?).to eq true
      end
    end

    context "when the value in the yaml file for the relationship is qualified_relative" do
      it "is false" do
        expect(described_class.new("aunt").qualifying_child_relationship?).to eq false
      end
    end
  end

  describe "#qualifying_relative_relationship?" do
    context "when the value in the yaml file for the relationship is qualified_relative" do
      it "is true" do
        expect(described_class.new("uncle").qualifying_relative_relationship?).to eq true
      end
    end

    context "when the value in the yaml file for the relationship is qualified_child" do
      it "is false" do
        expect(described_class.new("son").qualifying_relative_relationship?).to eq false
      end
    end
  end
end