require "rails_helper"

describe Efile::Relationship do
  context 'initialization' do
    context "when the passed in irs relationship category is not in the list of supported relationships" do
      it "raises an error" do
        expect {
          described_class.new("daughter", :qualifying_friend, "DAUGHTER", true, nil)
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
    context "when skip_relative_household_test is false" do
      context "from a yml relationship" do
        it "requires the household test" do
          expect(described_class.find("other").qualifying_relative_requires_member_of_household_test?).to eq true
        end
      end

      context "from instantiation" do
        it "is true" do
          instance = described_class.new("other", :qualifying_relative, "OTHER", false, nil)
          expect(instance.qualifying_relative_requires_member_of_household_test?).to eq true
        end
      end
    end
  end

  describe "#archived?" do
    context "from a yml relationship" do
      it "is accessible based on value in yml" do
        expect(described_class.find("other").archived?).to eq false
        expect(described_class.find("siblings_descendant").archived?).to eq true
      end
    end

    context "from instantiation" do
      context "when nil" do
        it "is accessible with value of false" do
          instance = described_class.new("other", :qualifying_relative, "OTHER", false, nil)
          expect(instance.archived?).to eq false
        end
      end
    end
  end
end
