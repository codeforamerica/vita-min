# == Schema Information
#
# Table name: state_file_dependents
#
#  id                                      :bigint           not null, primary key
#  ctc_qualifying                          :boolean
#  dob                                     :date
#  eic_disability                          :integer          default("unfilled")
#  eic_qualifying                          :boolean
#  eic_student                             :integer          default("unfilled")
#  first_name                              :string
#  id_has_grocery_credit_ineligible_months :integer          default("unfilled"), not null
#  id_months_ineligible_for_grocery_credit :integer
#  intake_type                             :string           not null
#  last_name                               :string
#  md_did_not_have_health_insurance        :integer          default("unfilled"), not null
#  middle_initial                          :string
#  months_in_home                          :integer
#  needed_assistance                       :integer          default("unfilled"), not null
#  nj_dependent_attends_accredited_program :integer          default("unfilled"), not null
#  nj_dependent_enrolled_full_time         :integer          default("unfilled"), not null
#  nj_dependent_five_months_in_college     :integer          default("unfilled"), not null
#  nj_did_not_have_health_insurance        :integer          default("unfilled"), not null
#  nj_filer_pays_tuition_for_dependent     :integer          default("unfilled"), not null
#  odc_qualifying                          :boolean
#  passed_away                             :integer          default("unfilled"), not null
#  qualifying_child                        :boolean
#  relationship                            :string
#  ssn                                     :string
#  suffix                                  :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  intake_id                               :bigint           not null
#
# Indexes
#
#  index_state_file_dependents_on_intake  (intake_type,intake_id)
#
FactoryBot.define do
  age_at_statefile_tax_year_end = ->(age) do
    DateTime.new(MultiTenantService.statefile.current_tax_year - age).end_of_year
  end

  factory :state_file_dependent do
    intake { create :state_file_az_intake }
    first_name { "Ali" }
    middle_initial {"U"}
    last_name { "Poppyseed" }
    relationship { "biologicalChild" }
    dob { age_at_statefile_tax_year_end.call(20) }

    factory :az_senior_dependent_missing_intake_answers do
      dob { age_at_statefile_tax_year_end.call(65) }
      months_in_home { 12 }
      relationship { "parent" }
    end

    factory :az_senior_dependent do
      dob { age_at_statefile_tax_year_end.call(65) }
      needed_assistance { "yes" }
      months_in_home { 12 }
      relationship { "parent" }
    end

    factory :az_senior_dependent_no_assistance do
      dob { age_at_statefile_tax_year_end.call(65) }
      needed_assistance { "no" }
      months_in_home { 12 }
      relationship { "parent" }
    end

    factory :az_hoh_qualifying_person_nonparent do
      dob { age_at_statefile_tax_year_end.call(55) }
      first_name { "Nonparent" }
      last_name { "Qualifying" }
      months_in_home { 12 }
      relationship { "biologicalChild" }
    end

    factory :az_hoh_qualifying_person_parent do
      dob { age_at_statefile_tax_year_end.call(64) }
      first_name { "Parent" }
      last_name { "Qualifying" }
      months_in_home { 0 }
      relationship { "parent" }
    end

    factory :az_hoh_nonqualifying_person_nonparent do
      dob { age_at_statefile_tax_year_end.call(60) }
      first_name { "Nonparent" }
      last_name { "Nonqualifying" }
      months_in_home { 5 }
      relationship { "biologicalChild" }
    end

    factory :az_hoh_nonqualifying_person_none_relationship do
      dob { age_at_statefile_tax_year_end.call(45) }
      first_name { "NoneRelationship" }
      last_name { "Nonqualifying" }
      months_in_home { 12 }
      relationship { "noneOfTheAbove" }
    end
  end
end