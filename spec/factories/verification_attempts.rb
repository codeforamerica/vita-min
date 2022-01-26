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
    client
    selfie { nil }
    photo_identification { nil }
    note_body { "This looks right to me. What do you think?" }

    transient do
      selfie_path { Rails.root.join("spec", "fixtures", "files", "picture_id.jpg") }
    end

    transient do
      photo_identification_path { Rails.root.join("spec", "fixtures", "files", "picture_id.jpg") }
    end
  end
end
