# == Schema Information
#
# Table name: efile_submission_transitions
#
#  id                  :bigint           not null, primary key
#  metadata            :jsonb
#  most_recent         :boolean          not null
#  sort_key            :integer          not null
#  to_state            :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  efile_submission_id :integer          not null
#
# Indexes
#
#  index_efile_submission_transitions_parent_most_recent  (efile_submission_id,most_recent) UNIQUE WHERE most_recent
#  index_efile_submission_transitions_parent_sort         (efile_submission_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (efile_submission_id => efile_submissions.id)
#
class EfileSubmissionTransition < ApplicationRecord
  belongs_to :efile_submission, inverse_of: :efile_submission_transitions, touch: true

  after_destroy :update_most_recent, if: :most_recent?

  private

  # If a transition is deleted, make the new last transition
  # the "most recent" to maintain proper functionality of most_recent? method.
  def update_most_recent
    last_transition = efile_submission.efile_submission_transitions.order(:sort_key).last
    last_transition.update_column(:most_recent, true) if last_transition.present?
  end
end
