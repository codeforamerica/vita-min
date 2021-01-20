# == Schema Information
#
# Table name: vita_partners
#
#  id                     :bigint           not null, primary key
#  accepts_overflow       :boolean          default(FALSE)
#  archived               :boolean          default(FALSE)
#  logo_path              :string
#  name                   :string           not null
#  weekly_capacity_limit  :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  coalition_id           :bigint
#  parent_organization_id :bigint
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

    factory :organization do
      sequence(:name) { |n| "Organization #{n}" }
      parent_organization { nil }
    end

    factory :site do
      sequence(:name) { |n| "Site #{n}" }
      parent_organization { create :organization }
    end
  end
end
