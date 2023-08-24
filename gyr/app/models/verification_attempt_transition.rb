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
class VerificationAttemptTransition < ApplicationRecord
  belongs_to :verification_attempt, inverse_of: :transitions

  after_destroy :update_most_recent, if: :most_recent?

  def initiated_by
    User.find(metadata['initiated_by_id']) if metadata['initiated_by_id'].present?
  end

  def note
    metadata['note']
  end

  private

  def update_most_recent
    last_transition = verification_attempt.transitions.order(:sort_key).last
    return unless last_transition.present?

    last_transition.update_column(:most_recent, true)
  end
end
