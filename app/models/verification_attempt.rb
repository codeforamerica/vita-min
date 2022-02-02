# == Schema Information
#
# Table name: verification_attempts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_verification_attempts_on_client_id  (client_id)
#
class VerificationAttempt < ApplicationRecord
  belongs_to :client
  has_one_attached :selfie
  has_one_attached :photo_identification
  has_many :verification_attempt_notes
end

