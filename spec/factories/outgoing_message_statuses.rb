# == Schema Information
#
# Table name: outgoing_messages
#
#  id              :bigint           not null, primary key
#  delivery_status :text
#  message_type    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :outgoing_message_status do
    trait :sms do
      message_type { :sms }
    end
  end
end
