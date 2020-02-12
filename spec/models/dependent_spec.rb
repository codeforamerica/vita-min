require "rails_helper"

describe Dependent do
  describe "validations" do

    it "requires essential fields" do
      dependent = Dependent.new

      expect(dependent).to_not be_valid
      expect(dependent.errors).to include :intake
      expect(dependent.errors).to include :first_name
      expect(dependent.errors).to include :last_name
      expect(dependent.errors).to include :birth_date
    end
  end

  describe "#full_name_and_birthdate" do
    let(:dependent) do
      build :dependent, first_name: "Kara", last_name: "Kiwi", birth_date: Date.new(2013, 5, 9)
    end

    it "returns a concatenated string with formatted date" do
      expect(dependent.full_name_and_birth_date).to eq "Kara Kiwi 5/9/2013"
    end
  end
end
