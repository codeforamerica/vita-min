# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  current_state       :string           default("intake_before_consent")
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
#  index_tax_returns_on_current_state       (current_state)
#  index_tax_returns_on_year                (year)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
class TaxReturn < ApplicationRecord
  has_many :tax_return_transitions, dependent: :destroy, autosave: false
  include Statesman::Adapters::ActiveRecordQueries[
              transition_class: TaxReturnTransition,
              initial_state: TaxReturnStateMachine.initial_state
          ]
  PRIMARY_SIGNATURE = "primary".freeze
  SPOUSE_SIGNATURE = "spouse".freeze
  belongs_to :client
  has_one :intake, through: :client
  belongs_to :assigned_user, class_name: "User", optional: true
  has_many :documents
  has_many :assignments, class_name: "TaxReturnAssignment", dependent: :destroy
  has_many :tax_return_selection_tax_returns, dependent: :destroy
  has_many :tax_return_selections, through: :tax_return_selection_tax_returns
  has_many :efile_submissions, dependent: :destroy
  has_one :accepted_tax_return_analytics
  enum certification_level: { advanced: 1, basic: 2, foreign_student: 3 }
  enum service_type: { online_intake: 0, drop_off: 1 }, _prefix: :service_type
  # The enum values map to the filing status codes dictated by the IRS
  enum filing_status: { single: 1, married_filing_jointly: 2, married_filing_separately: 3, head_of_household: 4, qualifying_widow: 5 }, _prefix: :filing_status
  validates :year, presence: true

  after_update_commit { InteractionTrackingService.record_internal_interaction(client) }
  after_save_commit { Client.refresh_filterable_properties([client_id]) }
  after_destroy_commit { Client.refresh_filterable_properties([client_id]) }

  def state_machine
    @state_machine ||= TaxReturnStateMachine.new(self, transition_class: TaxReturnTransition)
  end

  delegate :can_transition_to?, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, :advance_to, :previous_transition, :previous_state, :last_changed_by, to: :state_machine

  def current_state=(_)
    raise("Avoid writing to TaxReturn#current_state directly. Instead, use #transition_to or #transition_to!")
  end

  def ready_for_prep_at
    tax_return_transitions.order(:created_at).find_by(to_state: "prep_ready_for_prep")&.created_at
  end

  def qualifying_dependents
    client.qualifying_dependents(year)
  end

  def filing_status_code
    self.class.filing_statuses[filing_status]
  end

  def primary_age_65_or_older?
    intake.primary.birth_date.present? && intake.primary.birth_date < Date.new(year - 64, 1, 2)
  end

  def spouse_age_65_or_older?
    intake.spouse.birth_date.present? && intake.spouse.birth_date < Date.new(year - 64, 1, 2)
  end

  def standard_deduction
    AppliedStandardDeduction.new(tax_return: self).applied_standard_deduction
  end

  def has_submissions?
    efile_submissions.count.nonzero?
  end

  def self.service_type_options
    [[I18n.t("general.drop_off"), "drop_off"], [I18n.t("general.online"), "online_intake"]]
  end

  def filing_jointly?
    filing_status == "married_filing_jointly" || intake&.filing_joint == "yes"
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

  def ready_for_8879_signature?(signature_type)
    case signature_type
    when TaxReturn::PRIMARY_SIGNATURE
      return true if unsigned_8879s.present? && !primary_has_signed_8879?
    when TaxReturn::SPOUSE_SIGNATURE
      return true if unsigned_8879s.present? && filing_jointly? && !spouse_has_signed_8879?
    else
      raise StandardError, "Invalid signature_type parameter"
    end
    false
  end

  def completely_signed_8879?
    if filing_jointly?
      primary_has_signed_8879? && spouse_has_signed_8879?
    else
      primary_has_signed_8879?
    end
  end

  def ready_to_file?
    (filing_jointly? && primary_has_signed_8879? && spouse_has_signed_8879?) || (!filing_jointly? && primary_has_signed_8879?)
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
      else
        SystemNote::SignedDocument.generate!(signed_by_type: :spouse, waiting: true, tax_return: self)
      end
      save!
    end

    raise FailedToSignReturnError unless sign_successful

    true
  end

  def under_submission_limit?
    efile_submissions.count < 20
  end

  private

  def system_change_status(new_status)
    SystemNote::StatusChange.generate!(tax_return: self, old_status: current_state, new_status: new_status)
    transition_to(new_status)
  end
end

class FailedToSignReturnError < StandardError; end

class AlreadySignedError < StandardError; end
