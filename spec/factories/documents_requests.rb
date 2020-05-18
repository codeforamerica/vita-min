# == Schema Information
#
# Table name: documents_requests
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  intake_id  :bigint
#
# Indexes
#
#  index_documents_requests_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
FactoryBot.define do
  factory :documents_request do
    intake
  end
end
