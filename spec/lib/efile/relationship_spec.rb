require "rails_helper"

describe Efile::Relationship do
  context 'initialization' do
    context "when the passed in irs relationship category is not in the list of supported relationships" do
      it "raises an error" do
        expect {
          described_class.new("daughter", :qualifying_friend, "DAUGHTER", true)
        }.to raise_error RuntimeError
      end
    end
  end

  describe "#irs_enum" do
    it "retrieves the defined IRS enum for the relationship value" do
      expect(described_class.find("in_law").irs_enum).to eq "OTHER"
      expect(described_class.find("daughter").irs_enum).to eq "DAUGHTER"
    end
  end

  describe "#qualifying_child_relationship?" do
    context "when the value in the yaml file for the relationship is qualified_child" do
      it "is true" do
        expect(described_class.find("daughter").qualifying_child_relationship?).to eq true
      end
    end

    context "when the value in the yaml file for the relationship is qualified_relative" do
      it "is false" do
        expect(described_class.find("aunt").qualifying_child_relationship?).to eq false
      end
    end
  end

  describe "#qualifying_relative_relationship?" do
    context "when the value in the yaml file for the relationship is qualified_relative" do
      it "is true" do
        expect(described_class.find("uncle").qualifying_relative_relationship?).to eq true
      end
    end

    context "when the value in the yaml file for the relationship is qualified_child" do
      it "is false" do
        expect(described_class.find("son").qualifying_relative_relationship?).to eq false
      end
    end
  end

  describe "qualifying_relative_requires_member_of_household_test?" do

  end
end
