# == Schema Information
#
# Table name: verification_attempts
#
#  id                    :bigint           not null, primary key
#  client_bypass_request :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  client_id             :bigint
#
# Indexes
#
#  index_verification_attempts_on_client_id  (client_id)
#
class VerificationAttempt < ApplicationRecord
  VALID_FILE_TYPES = [".jpg", ".pdf", ".png"].freeze
  # TODO: check this list?
  VALID_MIME_TYPES = ["image/jpeg", "image/png", "image/heic", "image/bmp", "text/plain", "image/tiff", "image/gif"].freeze
  belongs_to :client
  has_one :intake, through: :client
  has_one_attached :selfie
  has_one_attached :photo_identification

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

  scope :open, -> { in_state(:new, :pending, :escalated, :restricted) }
  scope :reviewing, -> { in_state(:pending, :escalated, :restricted) }

  validate :only_one_open_attempt_per_client, on: :create
  validate :attachment_file_types

  def attachment_file_types
    [selfie, photo_identification].each do |attachment|
      if attachment.present?
        unless VALID_MIME_TYPES.include?(attachment.content_type)
          errors.add(attachment.name, I18n.t("validators.file_type", valid_types: VALID_FILE_TYPES.to_sentence))
        end
      end
    end
  end

  def only_one_open_attempt_per_client
    errors.add(:client, "only one open attempt is allowed per client") if client.verification_attempts.open.exists?
  end
end

