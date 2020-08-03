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
  validates :document_type, inclusion: { in: DocumentTypes::ALL_TYPES.map(&:key) }
  validates :intake, presence: { unless: :documents_request_id }

  scope :of_type, ->(type) { where(document_type: type) }

  belongs_to :intake, optional: true
  belongs_to :documents_request, optional: true
  has_one_attached :upload
end
