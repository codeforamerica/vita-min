# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  document_type        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  documents_request_id :bigint
#  intake_id            :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_documents_on_documents_request_id  (documents_request_id)
#  index_documents_on_intake_id             (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (documents_request_id => documents_requests.id)
#

class Document < ApplicationRecord
  MUST_HAVE_DOC_TYPES = [
    "1095-A",
    "1099-R",
    "ID",
    "SSN or ITIN",
    "Selfie",
  ]

  validates :document_type, inclusion: { in: DocumentNavigation::DOCUMENT_TYPES }
  validates :intake, presence: { unless: :documents_request_id }

  scope :of_type, ->(type) { where(document_type: type) }

  belongs_to :intake, optional: true
  belongs_to :documents_request, optional: true
  has_one_attached :upload

  def self.must_have_doc_type?(document_type)
    MUST_HAVE_DOC_TYPES.include?(document_type)
  end

  def self.might_have_doc_type?(document_type)
    !MUST_HAVE_DOC_TYPES.include?(document_type) && document_type != "Other"
  end
end
