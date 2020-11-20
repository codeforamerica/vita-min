# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  role            :integer          default("member"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_memberships_on_user_id          (user_id)
#  index_memberships_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :membership do
    vita_partner
  end

  factory :lead_membership, parent: :membership do
    role { "lead" }
  end
end
