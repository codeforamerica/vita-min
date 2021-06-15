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
  has_many :efile_submission_transitions, class_name: "EfileSubmissionTransition", autosave: false, dependent: :destroy

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EfileSubmissionTransition,
    initial_state: EfileSubmissionStateMachine.initial_state,
  ]

  def state_machine
    @state_machine ||= EfileSubmissionStateMachine.new(self, transition_class: EfileSubmissionTransition)
  end

  delegate :can_transition_to?, :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine
end
