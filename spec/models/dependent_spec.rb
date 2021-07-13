# == Schema Information
#
# Table name: dependents
#
#  id                      :bigint           not null, primary key
#  birth_date              :date
#  disabled                :integer          default("unfilled"), not null
#  encrypted_ip_pin        :string
#  encrypted_ip_pin_iv     :string
#  encrypted_ssn           :string
#  encrypted_ssn_iv        :string
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

  describe "#age_at_end_of_year" do
    let(:dependent) { build :dependent, birth_date: dob }
    let(:intake_double) { instance_double("Intake", tax_year: tax_year) }
    before { allow(dependent).to receive(:intake).and_return intake_double }

    context "a kid born the same year as the tax year" do
      let(:dob) { Date.new(2019, 12, 31) }
      let(:tax_year) { 2019 }
      it "returns 0" do
        expect(dependent.age_at_end_of_year(tax_year)).to eq 0
      end
    end

    context "a kid born in 2015 at end of 2019" do
      let(:dob) { Date.new(2015, 12, 25) }
      let(:tax_year) { 2019 }
      it "returns 4" do
        expect(dependent.age_at_end_of_year(tax_year)).to eq 4
      end
    end
  end

  describe "#mixpanel_data" do
    let(:dependent) do
      build(
        :dependent,
        birth_date: Date.new(2015, 6, 15),
        relationship: "Nibling",
        months_in_home: 12,
        was_student: "no",
        on_visa: "no",
        north_american_resident: "yes",
        disabled: "no",
        was_married: "no"
      )
    end

    it "returns the expected hash" do
      expect(dependent.mixpanel_data).to eq({
        dependent_age_at_end_of_tax_year: "4",
        dependent_under_6: "yes",
        dependent_months_in_home: "12",
        dependent_was_student: "no",
        dependent_on_visa: "no",
        dependent_north_american_resident: "yes",
        dependent_disabled: "no",
        dependent_was_married: "no",
      })
    end
  end
end
