# == Schema Information
#
# Table name: reports
#
#  id           :bigint           not null, primary key
#  data         :jsonb
#  generated_at :datetime
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_reports_on_generated_at  (generated_at)
#
FactoryBot.define do
  factory :report do
    
  end
end
