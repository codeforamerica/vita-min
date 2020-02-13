# == Schema Information
#
# Table name: dependents
#
#  id                      :bigint           not null, primary key
#  birth_date              :date
#  disabled                :integer          default("unfilled"), not null
#  first_name              :string
#  last_name               :string
#  months_in_home          :integer
#  north_american_resident :integer          default("unfilled"), not null
#  on_visa                 :integer          default("unfilled"), not null
#  relationship            :string
#  was_married             :integer          default("unfilled"), not null
#  was_student             :integer          default("unfilled"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  intake_id               :bigint           not null
#
# Indexes
#
#  index_dependents_on_intake_id  (intake_id)
#

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
