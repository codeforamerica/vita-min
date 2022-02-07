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
    client { create :client_with_ctc_intake_and_return }
    verification_attempt_notes { build_list :verification_attempt_note, 1 }
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
    after(:create) do |verification_attempt|
      create :ctc_intake, :filled_out_ctc, :with_bank_account
      create :bank_account, intake: verification_attempt.intake
    end
  end
end
