# == Schema Information
#
# Table name: efile_submissions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tax_return_id :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
class EfileSubmission < ApplicationRecord
  belongs_to :tax_return
  has_one :intake, through: :tax_return
  has_many :efile_submission_transitions, class_name: "EfileSubmissionTransition", autosave: false, dependent: :destroy

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EfileSubmissionTransition,
    initial_state: EfileSubmissionStateMachine.initial_state,
  ]

  def irs_submission_id
    Rails.logger.warn "Submission id overflow warning: modify irs_submission_id logic to prevent possible non-unique values" if id.digits.length > 11
    ("0%012d%7s" % [id, intake.primary_last_name.downcase.first(7)]).gsub(" ", "x")
  end

  def state_machine
    @state_machine ||= EfileSubmissionStateMachine.new(self, transition_class: EfileSubmissionTransition)
  end

  delegate :can_transition_to?, :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine
end
