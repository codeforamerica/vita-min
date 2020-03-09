# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  document_type     :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  intake_id         :bigint
#  zendesk_ticket_id :bigint
#
# Indexes
#
#  index_documents_on_intake_id  (intake_id)
#

class Document < ApplicationRecord
  validates :document_type, inclusion: { in: DocumentNavigation::DOCUMENT_TYPES }
  validates :intake, presence: true

  scope :of_type, ->(type) { where(document_type: type) }

  belongs_to :intake
  has_one_attached :upload
end
