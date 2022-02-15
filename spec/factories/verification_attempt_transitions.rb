# == Schema Information
#
# Table name: verification_attempt_transitions
#
#  id                      :bigint           not null, primary key
#  metadata                :jsonb
#  most_recent             :boolean          not null
#  sort_key                :integer          not null
#  to_state                :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  verification_attempt_id :integer          not null
#
# Indexes
#
#  index_verification_attempt_transitions_parent_most_recent  (verification_attempt_id,most_recent) UNIQUE WHERE most_recent
#  index_verification_attempt_transitions_parent_sort         (verification_attempt_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (verification_attempt_id => verification_attempts.id)
#
FactoryBot.define do
  factory :verification_attempt_transition do
    verification_attempt
    most_recent { true }
    sort_key { 0 }
    to_state { "pending" }
    VerificationAttemptStateMachine.states.each do |state|
      trait state.to_sym do
        to_state { state }
      end
    end
  end
end
