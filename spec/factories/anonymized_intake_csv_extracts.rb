# == Schema Information
#
# Table name: anonymized_intake_csv_extracts
#
#  id           :bigint           not null, primary key
#  record_count :integer
#  run_at       :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :anonymized_intake_csv_extract do
    run_at { "2020-07-01 18:36:46" }
    record_count { 1 }
  end
end
