# == Schema Information
#
# Table name: state_file_dependents
#
#  id                :bigint           not null, primary key
#  dob               :date
#  first_name        :string
#  intake_type       :string           not null
#  last_name         :string
#  middle_initial    :string
#  months_in_home    :integer
#  needed_assistance :integer          default(0), not null
#  passed_away       :integer          default(0), not null
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
  end
end
