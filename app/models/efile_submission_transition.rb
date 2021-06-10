class EfileSubmissionTransition < ApplicationRecord
  belongs_to :efile_submission, inverse_of: :state_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = efile_submission.state_transitions.order(:sort_key).last
    return unless last_transition.present?

    last_transition.update_column(:most_recent, true)
  end
end
