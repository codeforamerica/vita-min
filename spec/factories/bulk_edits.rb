# == Schema Information
#
# Table name: bulk_edits
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :bulk_edit do
  end
end