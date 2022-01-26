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
class VerificationAttempt < ApplicationRecord
  belongs_to :client

  # I'm guessing we will need to link somehow to Active_storage to define what selfie and photo_id are?
  has_one_attached :selfie
  has_one_attached :photo_id
end
