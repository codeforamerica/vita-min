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
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :vita_partner

  enum role: { member: 1, lead: 2 }
end
