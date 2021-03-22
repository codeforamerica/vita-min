# == Schema Information
#
# Table name: text_message_access_tokens
#
#  id               :bigint           not null, primary key
#  sms_phone_number :string           not null
#  token            :string           not null
#  token_type       :string           default("link")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_text_message_access_tokens_on_token  (token)
#
FactoryBot.define do
  factory :text_message_access_token do
    sms_phone_number { "+15005550006" }
    token { "randomly generated encrypted token" }
  end
end


