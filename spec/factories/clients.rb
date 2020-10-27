# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  response_needed_since        :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  vita_partner_id              :bigint
#
# Indexes
#
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :client do
    intake {
      create :intake,
      preferred_name: "George Michael",
      email_address: "gmichael@bluthsoriginalfrozenbanana.com",
      phone_number: "14155551212",
      sms_phone_number: "14155551212"
    }
  end
end
