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
require 'rails_helper'

RSpec.describe DeletedDocumentHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
