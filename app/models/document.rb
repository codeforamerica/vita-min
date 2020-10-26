# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  contact_record_type  :string
#  display_name         :string
#  document_type        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  contact_record_id    :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_documents_on_client_id                                  (client_id)
#  index_documents_on_contact_record_type_and_contact_record_id  (contact_record_type,contact_record_id)
#  index_documents_on_documents_request_id                       (documents_request_id)
#  index_documents_on_intake_id                                  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#

class Document < ApplicationRecord
  include InteractionTracking
  # Permit all existing document types, plus "Requested", which is superseded by "Requested Later" (but the DB has both)
  validates :document_type, inclusion: { in: DocumentTypes::ALL_TYPES.map(&:key) + ["Requested"] }
  validates :intake, presence: { unless: :documents_request_id }

  scope :of_type, ->(type) { where(document_type: type) }

  belongs_to :intake, optional: true
  belongs_to :client, optional: true
  belongs_to :documents_request, optional: true
  belongs_to :contact_record, polymorphic: true, optional: true
  has_one_attached :upload

  before_save :set_display_name

  after_create do
    client.present? ? record_incoming_interaction : intake&.record_incoming_interaction
  end

  def document_type_label
    DocumentTypes::ALL_TYPES.find { |doc_type_class| doc_type_class.key == document_type }
  end

  def set_display_name
    return if display_name

    if upload.present?
      self.display_name = upload.attachment.filename
    else
      self.display_name = "Untitled"
    end
  end
end
