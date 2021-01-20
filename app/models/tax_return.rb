# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  is_hsa              :boolean
#  primary_signature   :string
#  primary_signed_at   :datetime
#  primary_signed_ip   :inet
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

  enum status: TaxReturnStatus::STATUSES, _prefix: :status
  enum certification_level: { advanced: 1, basic: 2 }
  enum service_type: { online_intake: 0, drop_off: 1 }, _prefix: :service_type
  validates :year, presence: true
  
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

  def primary_has_signed?
    primary_signature.present? && primary_signed_at? && primary_signed_ip?
  end

  def spouse_has_signed?
    spouse_signature.present? && spouse_signed_at? && spouse_signed_ip?
  end

  def filing_joint?
    client.intake.filing_joint_yes?
  end

  def ready_for_signature?(signature_type)
    return false if signature_type == TaxReturn::PRIMARY_SIGNATURE && primary_has_signed?
    return false if signature_type == TaxReturn::SPOUSE_SIGNATURE && (spouse_has_signed? || !filing_joint?)
    return false if signed_8879.present?

    unsigned_8879.present?
  end

  def ready_to_file?
    (filing_joint? && primary_has_signed? && spouse_has_signed?) || (!filing_joint? && primary_has_signed?)
  end

  def unsigned_8879
    documents.find_by(document_type: DocumentTypes::UnsignedForm8879.key)
  end

  def signed_8879
    documents.find_by(document_type: DocumentTypes::CompletedForm8879.key)
  end

  def final_tax_documents
    documents.where(document_type: DocumentTypes::FinalTaxDocument.key)
  end

  def sign_primary!(ip)
    raise AlreadySignedError if primary_has_signed?

    sign_successful = ActiveRecord::Base.transaction do
      self.primary_signed_at = DateTime.current
      self.primary_signed_ip = ip
      self.primary_signature = client.legal_name

      if ready_to_file?
        system_change_status(:file_ready_to_file)
        Sign8879Service.create(self)
        client.set_attention_needed
      else
        SystemNote.create!(
          body: "Primary taxpayer signed #{year} form 8879. Waiting on spouse to sign.",
          client: client
        )
      end

      save!
    end

    raise FailedToSignReturnError if !sign_successful
    true
  end

  def sign_spouse!(ip)
    raise AlreadySignedError if spouse_has_signed?

    sign_successful = ActiveRecord::Base.transaction do
      self.spouse_signed_at = DateTime.current
      self.spouse_signed_ip = ip
      self.spouse_signature = client.spouse_legal_name

      if ready_to_file?
        system_change_status(:file_ready_to_file)
        Sign8879Service.create(self)
        client.set_attention_needed
      else
        SystemNote.create!(
          body: "Spouse of taxpayer signed #{year} form 8879. Waiting on primary taxpayer to sign.",
          client: client
        )
      end
      save!
    end

    raise FailedToSignReturnError if !sign_successful
    true
  end

  private

  def system_change_status(new_status)
    SystemNote.create_system_status_change_note!(self, self.status, new_status)
    self.status = new_status
  end
end

class FailedToSignReturnError < StandardError; end
class AlreadySignedError < StandardError; end
