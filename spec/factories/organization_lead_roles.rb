# == Schema Information
#
# Table name: organization_lead_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_organization_lead_roles_on_user_id          (user_id)
#  index_organization_lead_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :organization_lead_role do
    organization { create(:organization) }
    user { create(:user) }
  end
end
