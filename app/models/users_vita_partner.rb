# == Schema Information
#
# Table name: users_vita_partners
#
#  user_id         :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_users_vita_partners_on_user_id          (user_id)
#  index_users_vita_partners_on_vita_partner_id  (vita_partner_id)
#
class UsersVitaPartner < ApplicationRecord
  belongs_to :user
  belongs_to :vita_partner
end
