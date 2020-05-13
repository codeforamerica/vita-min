class DocumentsRequest < ApplicationRecord
  belongs_to :intake
  has_many :documents

  validates :intake, presence: true
end