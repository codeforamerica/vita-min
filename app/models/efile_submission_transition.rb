# == Schema Information
#
# Table name: efile_submission_transitions
#
#  id                    :bigint           not null, primary key
#  efile_submission_type :string           default("EfileSubmission"), not null
#  metadata              :jsonb
#  most_recent           :boolean          not null
#  sort_key              :integer          not null
#  to_state              :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  efile_submission_id   :integer          not null
#
# Indexes
#
#  index_efile_sub_transitions_on_efile_sub_type_and_efile_sub_id  (efile_submission_type,efile_submission_id)
#  index_efile_submission_transitions_on_created_at                (created_at)
#  index_efile_submission_transitions_parent_most_recent           (efile_submission_id,most_recent) UNIQUE WHERE most_recent
#  index_efile_submission_transitions_parent_sort                  (efile_submission_id,sort_key) UNIQUE
#
class EfileSubmissionTransition < ApplicationRecord
  # TODO: index on type of submission (PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "index_efile_submission_transitions_parent_sort")
  belongs_to :efile_submission, inverse_of: :efile_submission_transitions, touch: true, polymorphic: true
  has_many :efile_submission_transition_errors
  has_many :efile_errors, through: :efile_submission_transition_errors

  after_destroy :update_most_recent, if: :most_recent?

  default_scope { order(id: :asc) }

  def initiated_by
    return nil unless metadata["initiated_by_id"]

    User.find(metadata["initiated_by_id"])
  end

  def exposed_error
    return EfileError.none unless efile_errors.present?

    errors = efile_submission_transition_errors.joins(:efile_error).where(efile_errors: { expose: true })
    auto_cancel_errors = errors.where(efile_errors: { auto_cancel: true })
    auto_cancel_errors.any? ? auto_cancel_errors.first : errors.first
  end

  private

  # If a transition is deleted, make the new last transition
  # the "most recent" to maintain proper functionality of most_recent? method.
  def update_most_recent
    last_transition = efile_submission.efile_submission_transitions.order(:sort_key).last
    last_transition.update_column(:most_recent, true) if last_transition.present?
  end
end
