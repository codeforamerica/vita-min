# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  attention_needed_since       :datetime
#  current_sign_in_at           :datetime
#  current_sign_in_ip           :inet
#  failed_attempts              :integer          default(0), not null
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  last_sign_in_at              :datetime
#  last_sign_in_ip              :inet
#  locked_at                    :datetime
#  sign_in_count                :integer          default(0), not null
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
    trait :with_return do
      tax_returns { FactoryBot.create_list(:tax_return, 1, status: 101) }
    end
  end
end
