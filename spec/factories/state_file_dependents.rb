# == Schema Information
#
# Table name: state_file_dependents
#
#  id                :bigint           not null, primary key
#  ctc_qualifying    :boolean
#  dob               :date
#  eic_disability    :boolean
#  eic_qualifying    :boolean
#  eic_student       :boolean
#  first_name        :string
#  intake_type       :string           not null
#  last_name         :string
#  middle_initial    :string
#  months_in_home    :integer
#  needed_assistance :integer          default("unfilled"), not null
#  odc_qualifying    :boolean
#  passed_away       :integer          default("unfilled"), not null
#  relationship      :string
#  ssn               :string
#  suffix            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  intake_id         :bigint           not null
#
# Indexes
#
#  index_state_file_dependents_on_intake  (intake_type,intake_id)
#
FactoryBot.define do
  factory :state_file_dependent do
    intake
    first_name { "Ali" }
    middle_initial {"U"}
    last_name { "Poppyseed" }
    relationship { "DAUGHTER" }
    ssn { "123456789" }

    factory :az_senior_dependent_missing_intake_answers do
      dob { StateFileDependent.senior_cutoff_date }
      months_in_home { 12 }
      relationship { "PARENT" }
    end

    factory :az_senior_dependent do
      dob { StateFileDependent.senior_cutoff_date }
      needed_assistance { "yes" }
      months_in_home { 12 }
      relationship { "PARENT" }
    end

    factory :az_hoh_qualifying_person_nonparent do
      dob { StateFileDependent.senior_cutoff_date + 1.years }

      months_in_home { 12 }
      relationship { "DAUGHTER" }
    end

    factory :az_hoh_qualifying_person_parent do
      dob { StateFileDependent.senior_cutoff_date + 1.years }

      months_in_home { 0 }
      relationship { "PARENT" }
    end

    factory :az_hoh_nonqualifying_person_nonparent do
      dob { StateFileDependent.senior_cutoff_date + 1.years }

      months_in_home { 5 }
      relationship { "DAUGHTER" }
    end

    factory :az_hoh_nonqualifying_person_none_relationship do
      dob { StateFileDependent.senior_cutoff_date + 1.years }

      months_in_home { 12 }
      relationship { "NONE" }
    end
  end
end
