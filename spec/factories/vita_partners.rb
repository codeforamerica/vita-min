# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  accepts_itin_applicants    :boolean          default(FALSE)
#  allows_greeters            :boolean
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  processes_ctc              :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
#  type                       :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  coalition_id               :bigint
#  parent_organization_id     :bigint
#
# Indexes
#
#  index_vita_partners_on_coalition_id               (coalition_id)
#  index_vita_partners_on_parent_name_and_coalition  (parent_organization_id,name,coalition_id) UNIQUE
#  index_vita_partners_on_parent_organization_id     (parent_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
#
FactoryBot.define do
  sequence :name do |n|
    "Partner #{n}"
  end

  factory :vita_partner do
    name { generate :name }
  end

  factory :organization, class: 'Organization' do
    sequence(:name) { |n| "Organization #{n}" }
    capacity_limit { 100 }
    type { Organization::TYPE }
  end

  factory :site, class: 'Site' do
    sequence(:name) { |n| "Site #{n}" }
    parent_organization { create :organization }
    type { Site::TYPE }
  end
end
