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

FactoryBot.define do
  factory :dependent do
    intake
    first_name { "Kara" }
    last_name { "Kiwi" }
    birth_date { Date.new(2011, 3, 5) }
    relationship { "daughter" }
    north_american_resident { "yes" }
    on_visa { "no" }
    months_in_home { 11 }
    was_married { "no" }
    was_student { "yes" }
    disabled { "no" }
    sequence(:ssn) { |n| intake && intake.is_ctc? ? "88811#{"%04d" % (n % 1000)}" : nil }
    tin_type { intake && intake.is_ctc? ? "ssn" : nil }

    factory :qualifying_child do
      relationship { "niece" }
      birth_date { Date.new(2015, 2, 25) }
      full_time_student { "no" }
      permanently_totally_disabled { "no" }
      provided_over_half_own_support { "no" }
      filed_joint_return { "no" }
      months_in_home { 7 }
      cant_be_claimed_by_other { "yes" }
      claim_anyway { "yes" }
      tin_type { "ssn" }
      ssn { "123121234" }
    end

    factory :qualifying_relative do
      relationship { "parent" }
      ssn { "123121234" }
      filer_provided_over_half_support { "yes" }
      cant_be_claimed_by_other { "yes" }
      provided_over_half_own_support { "no" }
      # this was used for 2020 tax season, but not 2021. Change to "unfilled" after migrating to QualifyingRelative class
      meets_misc_qualifying_relative_requirements { "yes" }
    end

    factory :nonqualifying_dependent do
      relationship { "niece" }
      birth_date { Date.new(2015, 12, 25) }
      full_time_student { "no" }
      permanently_totally_disabled { "no" }
      provided_over_half_own_support { "no" }
      filed_joint_return { "no" }
      months_in_home { 6 }
      cant_be_claimed_by_other { "no" }
      claim_anyway { "yes" }
      tin_type { "ssn_no_employment" }
      ssn { "123121234" }
    end
  end
end
