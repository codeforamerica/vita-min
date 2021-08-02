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

  def initiated_by
    return nil unless metadata["initiated_by_id"]

    User.find(metadata["initiated_by_id"])
  end

  def stored_errors
    return [] unless rejection_parser.present? || metadata["error_code"] || metadata["error_message"]

    # coerce error_message/error_code style metadata into Efile::Error object format.
    return [Efile::Error.new(
      code: metadata["error_code"],
      message: metadata["error_message"]
    )] if metadata["error_message"].present? || metadata["error_code"].present?

    rejection_parser.errors
  end

  private

  def rejection_parser
    return unless to_state == "rejected" && metadata["raw_response"]

    @rejection_parser ||= Efile::SubmissionRejectionParser.new(metadata["raw_response"])
  end

  # If a transition is deleted, make the new last transition
  # the "most recent" to maintain proper functionality of most_recent? method.
  def update_most_recent
    last_transition = efile_submission.efile_submission_transitions.order(:sort_key).last
    last_transition.update_column(:most_recent, true) if last_transition.present?
  end
end
