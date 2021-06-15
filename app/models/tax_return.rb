# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  filing_status       :integer
#  filing_status_note  :text
#  internal_efile      :boolean          default(FALSE), not null
#  is_ctc              :boolean          default(FALSE)
#  is_hsa              :boolean
#  primary_signature   :string
#  primary_signed_at   :datetime
#  primary_signed_ip   :inet
#  ready_for_prep_at   :datetime
#  service_type        :integer          default("online_intake")
#  spouse_signature    :string
#  spouse_signed_at    :datetime
#  spouse_signed_ip    :inet
#  status              :integer          default("intake_before_consent"), not null
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assigned_user_id    :bigint
#  client_id           :bigint           not null
#
# Indexes
#
#  index_tax_returns_on_assigned_user_id    (assigned_user_id)
#  index_tax_returns_on_client_id           (client_id)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
class TaxReturn < ApplicationRecord

  PRIMARY_SIGNATURE = "primary".freeze
  SPOUSE_SIGNATURE = "spouse".freeze
  belongs_to :client
  belongs_to :assigned_user, class_name: "User", optional: true
  has_many :documents
  has_many :assignments, class_name: "TaxReturnAssignment", dependent: :destroy
  has_many :tax_return_selection_tax_returns, dependent: :destroy
  has_many :tax_return_selections, through: :tax_return_selection_tax_returns
  has_many :efile_submissions
  enum status: TaxReturnStatus::STATUSES, _prefix: :status
  enum certification_level: { advanced: 1, basic: 2, foreign_student: 3 }
  enum service_type: { online_intake: 0, drop_off: 1 }, _prefix: :service_type
  validates :year, presence: true

  attr_accessor :status_last_changed_by
  after_update_commit :send_mixpanel_status_change_event, :send_client_completion_survey
  after_update_commit { InteractionTrackingService.record_internal_interaction(client) }

  before_save do
    if status == "prep_ready_for_prep" && status_changed?
      self.ready_for_prep_at = DateTime.current
    end
  end

  ##
  # advance the return to a new status, only if that status more advanced.
  # An earlier or equal status will be ignored.
  #
  # @param [String] new_status: the name of the status to advance to
  #
  def advance_to(new_status)
    update!(status: new_status) if TaxReturn.statuses[status.to_sym] < TaxReturn.statuses[new_status.to_sym]
  end

  def self.filing_years
    [2020, 2019, 2018, 2017]
  end

  def self.service_type_options
    [[I18n.t("general.drop_off"), "drop_off"], [I18n.t("general.online"), "online_intake"]]
  end

  def primary_has_signed_8879?
    primary_signature.present? && primary_signed_after_unsigned_8879_upload? && primary_signed_ip?
  end

  def spouse_has_signed_8879?
    spouse_signature.present? && spouse_signed_after_unsigned_8879_upload? && spouse_signed_ip?
  end

  def primary_signed_after_unsigned_8879_upload?
    return false unless primary_signed_at.present?
    return true if unsigned_8879s.empty?

    unsigned_8879s.pluck(:created_at).max < primary_signed_at
  end

  def spouse_signed_after_unsigned_8879_upload?
    return false unless spouse_signed_at.present?
    return true if unsigned_8879s.empty?

    unsigned_8879s.pluck(:created_at).max < spouse_signed_at
  end

  def filing_joint?
    client.intake.filing_joint_yes?
  end

  def ready_for_8879_signature?(signature_type)
    case signature_type
    when TaxReturn::PRIMARY_SIGNATURE
      return true if unsigned_8879s.present? && !primary_has_signed_8879?
    when TaxReturn::SPOUSE_SIGNATURE
      return true if unsigned_8879s.present? && filing_joint? && !spouse_has_signed_8879?
    else
      raise StandardError, "Invalid signature_type parameter"
    end
    false
  end

  def completely_signed_8879?
    if filing_joint?
      primary_has_signed_8879? && spouse_has_signed_8879?
    else
      primary_has_signed_8879?
    end
  end

  def ready_to_file?
    (filing_joint? && primary_has_signed_8879? && spouse_has_signed_8879?) || (!filing_joint? && primary_has_signed_8879?)
  end

  def unsigned_8879s
    documents.active.where(document_type: DocumentTypes::UnsignedForm8879.key)
  end

  def signed_8879s
    documents.active.where(document_type: DocumentTypes::CompletedForm8879.key)
  end

  def final_tax_documents
    documents.active.where(document_type: DocumentTypes::FinalTaxDocument.key)
  end

  def sign_primary!(ip)
    unless unsigned_8879s.present?
      raise AlreadySignedError if primary_has_signed_8879?
    end

    sign_successful = ActiveRecord::Base.transaction do
      self.primary_signed_at = DateTime.current
      self.primary_signed_ip = ip
      self.primary_signature = client.legal_name || "N/A"

      if ready_to_file?
        system_change_status(:file_ready_to_file)
        Sign8879Service.create(self)
        SystemNote::SignedDocument.generate!(signed_by_type: :primary, tax_return: self)
        client.flag!
      else
        SystemNote::SignedDocument.generate!(signed_by_type: :primary, waiting: true, tax_return: self)
      end
      save!
    end

    raise FailedToSignReturnError unless sign_successful

    true
  end

  def sign_spouse!(ip)
    unless unsigned_8879s.present?
      raise AlreadySignedError if spouse_has_signed_8879?
    end

    sign_successful = ActiveRecord::Base.transaction do
      self.spouse_signed_at = DateTime.current
      self.spouse_signed_ip = ip
      self.spouse_signature = client.spouse_legal_name || "N/A"

      if ready_to_file?
        system_change_status(:file_ready_to_file)
        Sign8879Service.create(self)
        SystemNote::SignedDocument.generate!(signed_by_type: :spouse, tax_return: self)
        client.flag!
      else
        SystemNote::SignedDocument.generate!(signed_by_type: :spouse, waiting: true, tax_return: self)
      end
      save!
    end

    raise FailedToSignReturnError unless sign_successful

    true
  end

  def assign!(assigned_user: nil, assigned_by: nil)
    update!(assigned_user: assigned_user)
    SystemNote::AssignmentChange.generate!(initiated_by: assigned_by, tax_return: self)

    if assigned_user.present? && (assigned_user != assigned_by)
      UserNotification.create!(
        user: assigned_user,
        notifiable: TaxReturnAssignment.create!(
          assigner: assigned_by,
          tax_return: self
        )
      )
      UserMailer.assignment_email(
        assigned_user: assigned_user,
        assigning_user: assigned_by,
        assigned_at: updated_at,
        tax_return: self
      ).deliver_later
    end
  end

  private

  def send_mixpanel_status_change_event
    if saved_change_to_status?
      MixpanelService.send_status_change_event(self)

      if status == "file_rejected"
        MixpanelService.send_file_rejected_event(self)
      elsif status == "file_accepted"
        MixpanelService.send_file_accepted_event(self)
      elsif status == "prep_ready_for_prep"
        MixpanelService.send_tax_return_event(self, "ready_for_prep")
      elsif status == "file_efiled"
        MixpanelService.send_tax_return_event(self, "filing_filed")
      end
    end
  end

  def system_change_status(new_status)
    SystemNote::StatusChange.generate!(tax_return: self, old_status: self.status, new_status: new_status)
    self.status = new_status
  end

  def send_client_completion_survey
    if saved_change_to_status? && TaxReturnStatus::TERMINAL_STATUSES.map(&:to_s).include?(status)
      SendClientCompletionSurveyJob.set(wait_until: Time.current + 1.day).perform_later(client)
    end
  end
end

class FailedToSignReturnError < StandardError; end

class AlreadySignedError < StandardError; end
