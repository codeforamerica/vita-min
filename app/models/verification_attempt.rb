# == Schema Information
#
# Table name: verification_attempts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_verification_attempts_on_client_id  (client_id)
#
class VerificationAttempt < ApplicationRecord
  belongs_to :client
  has_one :intake, through: :client
  has_one_attached :selfie
  has_one_attached :photo_identification
  has_many :notes, class_name: "VerificationAttemptNote"

  has_many :transitions, class_name: "VerificationAttemptTransition", autosave: false
  include Statesman::Adapters::ActiveRecordQueries[
              transition_class: VerificationAttemptTransition,
              initial_state: VerificationAttemptStateMachine.initial_state,
              transition_name: :transitions
          ]

  def state_machine
    @state_machine ||= VerificationAttemptStateMachine.new(self, transition_class: VerificationAttemptTransition,
                                                                 association_name: :transitions)
  end

  delegate :can_transition_to?,
           :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine
end

