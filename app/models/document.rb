# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  contact_record_type  :string
#  display_name         :string
#  document_type        :string           default("Other"), not null
#  uploaded_by_type     :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  contact_record_id    :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  tax_return_id        :bigint
#  uploaded_by_id       :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_documents_on_client_id                                  (client_id)
#  index_documents_on_contact_record_type_and_contact_record_id  (contact_record_type,contact_record_id)
#  index_documents_on_documents_request_id                       (documents_request_id)
#  index_documents_on_intake_id                                  (intake_id)
#  index_documents_on_tax_return_id                              (tax_return_id)
#  index_documents_on_uploaded_by_type_and_uploaded_by_id        (uploaded_by_type,uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#  fk_rails_...  (tax_return_id => tax_returns.id)
#

class Document < ApplicationRecord
  include InteractionTracking
  # Permit all existing document types, plus "Requested", which is superseded by "Requested Later" (but the DB has both)
  validates :document_type, inclusion: { in: DocumentTypes::ALL_TYPES.map(&:key) + ["Requested"] }
  validates_presence_of :client

  default_scope { order(created_at: :asc) }

  scope :of_type, ->(type) { where(document_type: type) }

  belongs_to :intake, optional: true
  belongs_to :client
  belongs_to :documents_request, optional: true
  belongs_to :contact_record, polymorphic: true, optional: true
  belongs_to :tax_return, optional: true
  belongs_to :uploaded_by, polymorphic: true, optional: true
  has_one_attached :upload
  validates :upload, presence: true
  validate :tax_return_belongs_to_client

  before_save :set_display_name

  after_create do
    uploaded_by.is_a?(User) ? record_internal_interaction : record_incoming_interaction
  end

  def document_type_label
    DocumentTypes::ALL_TYPES.find { |doc_type_class| doc_type_class.key == document_type } || document_type
  end

  def set_display_name
    return if display_name.present?

    self.display_name = upload.attachment.filename
  end

  def tax_return_belongs_to_client
    errors.add(:tax_return, I18n.t("forms.errors.tax_return_belongs_to_client")) unless tax_return.blank? || tax_return.client == client
  end
end
