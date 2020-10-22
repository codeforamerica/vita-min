# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  email_address                :string
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  phone_number                 :string
#  preferred_name               :string
#  response_needed_since        :datetime
#  sms_phone_number             :string
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
    transient do
    end
    preferred_name { "Casey" }
    email_address { "client@example.com" }
    phone_number { "14155551212" }
    sms_phone_number { "14155551212" }

    after(:create) do |client|
      if client.intake.present?
        client.intake.update(preferred_name: client.preferred_name)
      else
        intake = create(:intake, preferred_name: client.preferred_name)
        client.update(intake: intake)
      end
    end
  end
end
