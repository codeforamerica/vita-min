# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                   :bigint           not null, primary key
#  claimed_as_dep       :integer
#  current_step         :string
#  raw_direct_file_data :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  visitor_id           :string
#
FactoryBot.define do
  factory :state_file_az_intake do
    raw_direct_file_data { File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml')) }
    claimed_as_dep { 'no' }
  end
end
