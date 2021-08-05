# == Schema Information
#
# Table name: dependents
#
#  id                                          :bigint           not null, primary key
#  birth_date                                  :date
#  born_in_2020                                :integer          default("unfilled"), not null
#  cant_be_claimed_by_other                    :integer          default("unfilled"), not null
#  claim_anyway                                :integer          default("unfilled"), not null
#  disabled                                    :integer          default("unfilled"), not null
#  encrypted_ip_pin                            :string
#  encrypted_ip_pin_iv                         :string
#  encrypted_ssn                               :string
#  encrypted_ssn_iv                            :string
#  filed_joint_return                          :integer          default("unfilled"), not null
#  first_name                                  :string
#  full_time_student                           :integer          default("unfilled"), not null
#  has_ip_pin                                  :integer          default("unfilled"), not null
#  last_name                                   :string
#  lived_with_more_than_six_months             :integer          default("unfilled"), not null
#  meets_misc_qualifying_relative_requirements :integer          default("unfilled"), not null
#  middle_initial                              :string
#  months_in_home                              :integer
#  no_ssn_atin                                 :integer          default("unfilled"), not null
#  north_american_resident                     :integer          default("unfilled"), not null
#  on_visa                                     :integer          default("unfilled"), not null
#  passed_away_2020                            :integer          default("unfilled"), not null
#  permanent_residence_with_client             :integer          default("unfilled"), not null
#  permanently_totally_disabled                :integer          default("unfilled"), not null
#  placed_for_adoption                         :integer          default("unfilled"), not null
#  provided_over_half_own_support              :integer          default("unfilled"), not null
#  relationship                                :string
#  suffix                                      :string
#  tin_type                                    :integer
#  was_married                                 :integer          default("unfilled"), not null
#  was_student                                 :integer          default("unfilled"), not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  intake_id                                   :bigint           not null
#
# Indexes
#
#  index_dependents_on_intake_id  (intake_id)
#

require "rails_helper"

describe Dependent do
  it "strips leading or trailing spaces from any free-text attributes" do
    dependent = Dependent.new(
      first_name: "  doug",
      last_name: "  douglasson",
      middle_initial: "   XYZ ",
      ssn: "000000000 ",
      ip_pin: "000111 "
    )
    dependent.valid?
    expect(dependent.attributes).to match(a_hash_including({
      "first_name" => "doug",
      "last_name" => "douglasson",
      "middle_initial" => "XYZ",
    }))
    expect(dependent.ip_pin).to eq("000111")
    expect(dependent.ssn).to eq("000000000")
  end

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

  describe "irs_relationship_enum" do
    context "foster_child" do
      let(:dependent) { build :dependent, relationship: "foster_child" }
      it "converts to upcase without underscores" do
        expect(dependent.irs_relationship_enum).to eq "FOSTER CHILD"
      end
    end

    context "half_brother" do
      let(:dependent) { build :dependent, relationship: "half_brother" }

      it "converts to upcase without underscores" do
        expect(dependent.irs_relationship_enum).to eq "HALF BROTHER"
      end
    end

    context "stepchild" do
      let(:dependent) { build :dependent, relationship: "stepchild" }

      it "converts to upcase without underscores" do
        expect(dependent.irs_relationship_enum).to eq "STEPCHILD"
      end
    end
  end

  describe "#last_four_ssn" do
    context "with an SSN filled out" do
      let(:dependent) { build :dependent, ssn: "123456789" }

      it "returns the last four digits" do
        expect(dependent.last_four_ssn).to eq "6789"
      end
    end

    context "without an SSN filled out" do
      let(:dependent) { build :dependent, ssn: nil }

      it "returns nil" do
        expect(dependent.last_four_ssn).to be_nil
      end
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

  describe "#qualifying_child_2020?" do
    context "with a qualifying child" do
      let(:dependent) do
        build :dependent,
              relationship: "NIECE",
              birth_date: Date.new(2015, 12, 25),
              full_time_student: "no",
              permanently_totally_disabled: "no",
              provided_over_half_own_support: "no",
              no_ssn_atin: "no",
              filed_joint_return: "no",
              lived_with_more_than_six_months: "yes",
              cant_be_claimed_by_other: "no",
              claim_anyway: "yes"
      end

      it "returns true" do
        expect(dependent.qualifying_child_2020?).to eq true
      end
    end

    context "with a child that does not qualify" do
      let(:dependent) do
        build :dependent,
              relationship: "niece",
              birth_date: Date.new(2015, 12, 25),
              full_time_student: "no",
              permanently_totally_disabled: "no",
              provided_over_half_own_support: "no",
              no_ssn_atin: "no",
              filed_joint_return: "no",
              lived_with_more_than_six_months: "no",
              cant_be_claimed_by_other: "no",
              claim_anyway: "yes"
      end

      it "returns false" do
        expect(dependent.qualifying_child_2020?).to eq false
      end
    end
  end

  describe "#meets_qc_age_condition_2020?" do
    context "with a dependent that is under 19" do
      let(:dependent) { build :dependent, birth_date: Date.new(2015, 12, 25) }

      it "returns true" do
        expect(dependent.meets_qc_age_condition_2020?).to eq true
      end
    end

    context "with a dependent that is between 19 and 24 and a full time student" do
      let(:dependent) { build :dependent, birth_date: Date.new(1999, 12, 25), full_time_student: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_age_condition_2020?).to eq true
      end
    end

    context "with a dependent that is over 24 but disabled" do
      let(:dependent) { build :dependent, birth_date: Date.new(1980, 12, 25), permanently_totally_disabled: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_age_condition_2020?).to eq true
      end
    end

    context "with a dependent that is over 19 and not a student, not disabled" do
      let(:dependent) { build :dependent, birth_date: Date.new(1997, 12, 25), full_time_student: "no", permanently_totally_disabled: "no" }

      it "returns false" do
        expect(dependent.meets_qc_age_condition_2020?).to eq false
      end
    end
  end

  describe "#meets_qc_misc_conditions?" do
    context "with a dependent that paid for more than half their expenses" do
      let(:dependent) { build :dependent, provided_over_half_own_support: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_misc_conditions?).to eq false
      end
    end

    context "with a dependent that does not have an ssn/atin" do
      let(:dependent) { build :dependent, no_ssn_atin: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_misc_conditions?).to eq false
      end
    end

    context "with a dependent that is married and filing jointly" do
      let(:dependent) { build :dependent, filed_joint_return: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_misc_conditions?).to eq false
      end
    end

    context "with a dependent that is none of the above" do
      let(:dependent) { build :dependent, provided_over_half_own_support: "no", no_ssn_atin: "no", filed_joint_return: "no" }

      it "returns false" do
        expect(dependent.meets_qc_misc_conditions?).to eq true
      end
    end
  end

  describe "#meets_qc_residence_condition_2020?" do
    context "with a dependent that lived with the client for 6 months or more" do
      let(:dependent) { build :dependent, lived_with_more_than_six_months: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_residence_condition_2020?).to eq true
      end
    end

    context "with a dependent that lived with the client for less than 6 months" do
      let(:dependent) { build :dependent, lived_with_more_than_six_months: "no" }

      context "doesn't meet an exception" do
        it "returns false" do
          expect(dependent.meets_qc_residence_condition_2020?).to eq false
        end
      end

      context "meets an exception" do
        it "returns true" do
          [:born_in_2020, :passed_away_2020, :placed_for_adoption, :permanent_residence_with_client].each do |field|
            dependent[field] = "yes"
            expect(dependent.meets_qc_residence_condition_2020?).to eq true
          end
        end
      end
    end
  end

  describe "#meets_qc_claimant_condition?" do
    context "with a dependent that cannot be claimed by another" do
      let(:dependent) { build :dependent, cant_be_claimed_by_other: "yes" }

      it "returns true" do
        expect(dependent.meets_qc_claimant_condition?).to eq true
      end
    end

    context "with a dependent that can be claimed by another" do
      context "and is claimed anyways" do
        let(:dependent) { build :dependent, cant_be_claimed_by_other: "no", claim_anyway: "yes" }

        it "returns true" do
          expect(dependent.meets_qc_claimant_condition?).to eq true
        end
      end

      context "and is not claimed anyways" do
        let(:dependent) { build :dependent, cant_be_claimed_by_other: "no", claim_anyway: "no" }

        it "returns false" do
          expect(dependent.meets_qc_claimant_condition?).to eq false
        end
      end
    end
  end

  describe "#qualifying_relative_2020?" do
    let(:dependent) do
      build :dependent,
            relationship: relationship,
            birth_date: birthday,
            filed_joint_return: filed_jointly,
            meets_misc_qualifying_relative_requirements: meets_misc
    end
    let(:relationship) { "nephew" }
    let(:birthday) { Date.new(2000, 12, 25) }
    let(:filed_jointly) { "no" }

    context "with a dependent who meets misc requirements" do
      let(:meets_misc) { "yes" }

      context "with a dependent who has a QC relationship but doesn't meet age conditions" do
        let(:birthday) { Date.new(1960, 12, 25) }

        it "returns true" do
          expect(dependent.qualifying_relative_2020?).to eq true
        end
      end

      context "with a dependent who has a QC relationship and does meet age conditions but filed jointly with their spouse" do
        let(:filed_jointly) { "yes" }

        it "returns true" do
          expect(dependent.qualifying_relative_2020?).to eq true
        end
      end

      context "with a dependent who has a QR relationship" do
        let(:relationship) { "parent" }

        it "returns true" do
          expect(dependent.qualifying_relative_2020?).to eq true
        end
      end
    end

    context "with a dependent who does not meet misc requirements" do
      let(:meets_misc) { "no" }

      it "returns false" do
        expect(dependent.qualifying_relative_2020?).to eq false
      end
    end
  end

  describe "#qualifying?" do
    context "with a qualifying child" do
      let(:dependent) { create :qualifying_child }

      it "returns true" do
        expect(dependent.qualifying_2020?).to eq true
      end
    end

    context "with a qualifying relative" do
      let(:dependent) { create :qualifying_relative }

      it "returns true" do
        expect(dependent.qualifying_2020?).to eq true
      end
    end

    context "with a dependent that does not qualify" do
      let(:dependent) { create :nonqualifying_dependent }

      it "returns false" do
        expect(dependent.qualifying_2020?).to eq false
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

  context "eligibility for special credits" do
    context "when a qualifying child" do
      context "when under 17 " do
        context "with an atin" do
          let(:dependent) { create :qualifying_child, birth_date: Date.new(2004, 1, 1), tin_type: :atin }
          it "is qualified for eip but not ctc" do
            expect(dependent.eligible_for_eip2?).to eq true
            expect(dependent.eligible_for_eip1?).to eq true
            expect(dependent.eligible_for_child_tax_credit_2020?).to eq false
          end
        end

        context "with an ssn" do
          let(:dependent) { create :qualifying_child, birth_date: Date.new(2004, 1, 1), tin_type: :ssn }

          it "is qualified for all special credits" do
            expect(dependent.eligible_for_eip2?).to eq true
            expect(dependent.eligible_for_eip1?).to eq true
            expect(dependent.eligible_for_child_tax_credit_2020?).to eq true
          end
        end
      end

      context "when over 17" do
        let(:dependent) { create :qualifying_child, birth_date: Date.new(2003, 12, 31) }

        it "is false for all special credits" do
          expect(dependent.eligible_for_eip2?).to eq false
          expect(dependent.eligible_for_eip1?).to eq false
          expect(dependent.eligible_for_child_tax_credit_2020?).to eq false
        end
      end
    end

    context "when not a qualifying child" do
      let(:dependent) { create :qualifying_relative }
      it "is false for all special credits" do
        expect(dependent.eligible_for_eip2?).to eq false
        expect(dependent.eligible_for_eip1?).to eq false
        expect(dependent.eligible_for_child_tax_credit_2020?).to eq false
      end
    end
  end
end
