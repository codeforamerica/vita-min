# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  display_name         :string
#  document_type        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_documents_on_client_id             (client_id)
#  index_documents_on_documents_request_id  (documents_request_id)
#  index_documents_on_intake_id             (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#

FactoryBot.define do
  factory :document do
    intake
    upload { nil }
    document_type { "W-2" }

    trait :with_upload do
      transient do
        upload_path { Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg") }
      end

      after(:build) do |document, evaluator|
        document.upload.attach(
          io: File.open(evaluator.upload_path),
          filename: File.basename(evaluator.upload_path)
        )
      end
    end
  end
end
