# == Schema Information
#
# Table name: spouse_verification_requests
#
#  id                   :bigint           not null, primary key
#  email                :string
#  phone_number         :string
#  sent_at              :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  intake_id            :bigint           not null
#  user_id              :bigint
#  zendesk_requester_id :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_spouse_verification_requests_on_intake_id  (intake_id)
#  index_spouse_verification_requests_on_user_id    (user_id)
#

class SpouseVerificationRequest < ApplicationRecord
  belongs_to :intake
end
