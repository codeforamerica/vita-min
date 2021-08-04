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
  has_many :efile_submission_transition_errors
  has_many :efile_errors, through: :efile_submission_transition_errors

  after_destroy :update_most_recent, if: :most_recent?
  after_create :persist_efile_error_from_metadata

  def initiated_by
    return nil unless metadata["initiated_by_id"]

    User.find(metadata["initiated_by_id"])
  end

  def client_facing_errors
    return EfileError.none unless efile_errors.present?

    efile_errors.where(expose: true)
  end

  private

  def rejection_parser
    return unless to_state == "rejected" && metadata["raw_response"]

    @rejection_parser ||= Efile::SubmissionRejectionParser.new(metadata["raw_response"])
  end

  def persist_efile_error_from_metadata
    if metadata["error_code"].present?
      attrs = { code: metadata["error_code"] }
      attrs.merge(message: metadata["error_message"]) if metadata["error_message"].present?
      efile_error = EfileError.find_or_create_by!(attrs)
      self.efile_submission_transition_errors.create(efile_submission_id: efile_submission.id, efile_error: efile_error)
    end

    if to_state == "rejected" && metadata["raw_response"].present?
      Efile::SubmissionRejectionParser.new(self).persist_errors
    end
  end

  # If a transition is deleted, make the new last transition
  # the "most recent" to maintain proper functionality of most_recent? method.
  def update_most_recent
    last_transition = efile_submission.efile_submission_transitions.order(:sort_key).last
    last_transition.update_column(:most_recent, true) if last_transition.present?
  end
end
