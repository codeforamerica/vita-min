# == Schema Information
#
# Table name: documents_requests
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  client_id    :bigint
#
# Indexes
#
#  index_documents_requests_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
FactoryBot.define do
  factory :documents_request do
    client
  end
end
