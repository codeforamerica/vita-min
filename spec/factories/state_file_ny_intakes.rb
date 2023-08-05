# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                 :bigint           not null, primary key
#  primary_first_name :string
#  primary_last_name  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :state_file_ny_intake do
    first_name { "MyString" }
  end
end
