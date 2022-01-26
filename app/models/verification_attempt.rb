class VerificationAttempt < ApplicationRecord
  belongs_to :client

  # I'm guessing we will need to link somehow to Active_storage to define what selfie and photo_id are?
  has_one_attached :selfie
  has_one_attached :photo_id
end
