# == Schema Information
#
# Table name: state_efile_submissions
#
#  id                      :bigint           not null, primary key
#  intake_type             :string           not null
#  last_checked_for_ack_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  intake_id               :bigint           not null
#  irs_submission_id       :string
#
# Indexes
#
#  index_state_efile_submissions_on_intake  (intake_type,intake_id)
#
class StateEfileSubmission < ApplicationRecord
  belongs_to :intake, polymorphic: true, optional: true
  has_many :efile_submission_transitions, -> { order(id: :asc) }, as: :efile_submission, class_name: "EfileSubmissionTransition", autosave: false, dependent: :destroy
  has_one_attached :submission_bundle
  validates :irs_submission_id, format: { with: /\A[0-9]{6}[0-9]{7}[0-9a-z]{7}\z/ }, presence: true, allow_nil: true #uniqueness: true

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EfileSubmissionTransition,
    initial_state: EfileSubmissionStateMachine.initial_state,
  ]

  def state_machine
    @state_machine ||= EfileSubmissionStateMachine.new(self, transition_class: EfileSubmissionTransition)
  end

  def create_qualifying_dependents; end

  delegate :can_transition_to?, :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine
end
