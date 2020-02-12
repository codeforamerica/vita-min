# == Schema Information
#
# Table name: documents
#
#  id            :bigint           not null, primary key
#  document_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  intake_id     :bigint
#
# Indexes
#
#  index_documents_on_intake_id  (intake_id)
#

class Document < ApplicationRecord
  # For the document overview page, we need a mapping of which controller
  # corresponds to which Document Type.
  DOCUMENT_CONTROLLERS = {
    "W-2" => Questions::W2sController,
    "Other" => Questions::AdditionalDocumentsController,
  }.freeze
  DOCUMENT_TYPES = DOCUMENT_CONTROLLERS.keys.freeze

  validates :document_type, inclusion: { in: DOCUMENT_TYPES }
  validates :intake, presence: true

  scope :of_type, ->(type) { where(document_type: type) }

  belongs_to :intake
  has_one_attached :upload
end
