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
FactoryBot.define do
  factory :verification_attempt do
    client

    after(:build) do |verification_attempt|
      verification_attempt.selfie.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
      verification_attempt.photo_identification.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
