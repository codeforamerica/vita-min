# == Schema Information
#
# Table name: outgoing_message_statuses
#
#  id              :bigint           not null, primary key
#  delivery_status :text
#  message_type    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  message_id      :text
#
FactoryBot.define do
  factory :outgoing_message_status do
    sequence(:message_id) { |n| "msgid_#{n}" }

    trait :sms do
      message_type { :sms }
    end

    trait :email do
      message_type { :email }
    end
  end
end
