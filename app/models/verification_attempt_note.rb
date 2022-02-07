# == Schema Information
#
# Table name: verification_attempt_notes
#
#  id                      :bigint           not null, primary key
#  body                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint
#  verification_attempt_id :bigint
#
# Indexes
#
#  index_verification_attempt_notes_on_user_id                  (user_id)
#  index_verification_attempt_notes_on_verification_attempt_id  (verification_attempt_id)
#
class VerificationAttemptNote < ApplicationRecord
  belongs_to :verification_attempt
  belongs_to :user
end
