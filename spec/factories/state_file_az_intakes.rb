# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                     :bigint           not null, primary key
#  claimed_as_dep         :integer
#  current_step           :string
#  primary_first_name     :string
#  primary_last_name      :string
#  primary_middle_initial :string
#  raw_direct_file_data   :text
#  spouse_first_name      :string
#  spouse_last_name       :string
#  spouse_middle_initial  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  visitor_id             :string
#
FactoryBot.define do
  factory :state_file_az_intake do
    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    claimed_as_dep { 'no' }
    primary_first_name { "Ariz" }
    primary_last_name { "Onian" }
  end
end
