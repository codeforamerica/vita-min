# == Schema Information
#
# Table name: documents_requests
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  intake_id    :bigint
#
# Indexes
#
#  index_documents_requests_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
class DocumentsRequest < ApplicationRecord
  belongs_to :intake
  has_many :documents

  validates :intake, presence: true
end
