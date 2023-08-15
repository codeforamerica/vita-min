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
FactoryBot.define do
  factory :deleted_document_history do
    association :document, factory: :document
    association :client
    document_id { 1 }
    document_type { "MyString" }
    deleted_at { "2023-08-14 13:14:19" }
  end
end
