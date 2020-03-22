# == Schema Information
#
# Table name: provider_scrapes
#
#  id             :bigint           not null, primary key
#  archived_count :integer          default(0), not null
#  changed_count  :integer          default(0), not null
#  created_count  :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :provider_scrape
end
