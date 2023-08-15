# == Schema Information
#
# Table name: deleted_document_histories
#
#  id            :bigint           not null, primary key
#  deleted_at    :datetime
#  display_name  :string
#  document_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :bigint
#  document_id   :integer
#
# Indexes
#
#  index_deleted_document_histories_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class DeletedDocumentHistory < ApplicationRecord
  belongs_to :document
  belongs_to :client
end

