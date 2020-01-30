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

FactoryBot.define do
  factory :document do
    intake
    document_type { "W-2" }
  end
end
