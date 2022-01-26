# == Schema Information
#
# Table name: verification_attempts
#
#  id         :bigint           not null, primary key
#  note_body  :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_verification_attempts_on_client_id  (client_id)
#
FactoryBot.define do
  factory :verification_attempt do
    
  end
end
