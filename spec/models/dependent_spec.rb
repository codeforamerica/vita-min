# == Schema Information
#
# Table name: dependents
#
#  id                                           :bigint           not null, primary key
#  below_qualifying_relative_income_requirement :integer          default("unfilled")
#  birth_date                                   :date             not null
#  cant_be_claimed_by_other                     :integer          default("unfilled"), not null
#  claim_anyway                                 :integer          default("unfilled"), not null
#  creation_token                               :string
#  disabled                                     :integer          default("unfilled"), not null
#  filed_joint_return                           :integer          default("unfilled"), not null
#  filer_provided_over_half_housing_support     :integer          default("unfilled"), not null
#  filer_provided_over_half_support             :integer          default("unfilled")
#  first_name                                   :string
#  full_time_student                            :integer          default("unfilled"), not null
#  has_ip_pin                                   :integer          default("unfilled"), not null
#  ip_pin                                       :text
#  last_name                                    :string
#  lived_with_more_than_six_months              :integer          default("unfilled"), not null
#  meets_misc_qualifying_relative_requirements  :integer          default("unfilled"), not null
#  middle_initial                               :string
#  months_in_home                               :integer
#  no_ssn_atin                                  :integer          default("unfilled"), not null
#  north_american_resident                      :integer          default("unfilled"), not null
#  on_visa                                      :integer          default("unfilled"), not null
#  permanent_residence_with_client              :integer          default("unfilled"), not null
#  permanently_totally_disabled                 :integer          default("unfilled"), not null
#  provided_over_half_own_support               :integer          default("unfilled"), not null
#  relationship                                 :string
#  residence_exception_adoption                 :integer          default("unfilled"), not null
#  residence_exception_born                     :integer          default("unfilled"), not null
#  residence_exception_passed_away              :integer          default("unfilled"), not null
#  residence_lived_with_all_year                :integer          default("unfilled")
#  soft_deleted_at                              :datetime
#  ssn                                          :text
#  suffix                                       :string
#  tin_type                                     :integer
#  was_married                                  :integer          default("unfilled"), not null
#  was_student                                  :integer          default("unfilled"), not null
#  created_at                                   :datetime         not null
#  updated_at                                   :datetime         not null
#  intake_id                                    :bigint           not null
#
# Indexes
#
#  index_dependents_on_creation_token  (creation_token)
#  index_dependents_on_intake_id       (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
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

  context "destroying" do
    let(:dependent) { create :dependent, relationship: "stepchild" }
    let(:error) { create :efile_submission_transition_error, dependent: dependent }
    it "removes associations from EfileSubmissionTransitionError objects" do
      expect(error.dependent).to eq dependent
      dependent.destroy!
      expect(error.reload.dependent_id).to eq nil
    end
  end
end
