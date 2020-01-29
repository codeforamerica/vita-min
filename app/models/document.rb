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
  DOCUMENT_TYPES = [
    "W-2",
    "Other"
  ].freeze

  validates :document_type, inclusion: { in: DOCUMENT_TYPES }
  validates :intake, presence: true

  belongs_to :intake
  has_one_attached :upload
end
