
# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  archived             :boolean          default(FALSE), not null
#  contact_record_type  :string
#  display_name         :string
#  document_type        :string           not null
#  uploaded_by_type     :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  contact_record_id    :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  tax_return_id        :bigint
#  uploaded_by_id       :bigint
#
# Indexes
#
#  index_documents_on_client_id                                  (client_id)
#  index_documents_on_contact_record_type_and_contact_record_id  (contact_record_type,contact_record_id)
#  index_documents_on_documents_request_id                       (documents_request_id)
#  index_documents_on_intake_id                                  (intake_id)
#  index_documents_on_tax_return_id                              (tax_return_id)
#  index_documents_on_uploaded_by_type_and_uploaded_by_id        (uploaded_by_type,uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#  fk_rails_...  (tax_return_id => tax_returns.id)
#

FactoryBot.define do
  factory :document do
    intake
    client { intake.client }
    upload { nil }
    document_type { DocumentTypes::Employment.key }

    transient do
      upload_path { Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg") }
    end

    trait :pdf do
      transient do
        upload_path { Rails.root.join("spec", "fixtures", "attachments", "document_bundle.pdf") }
      end
    end
    after(:build) do |document, evaluator|
      document.upload.attach(
        io: File.open(evaluator.upload_path),
        filename: File.basename(evaluator.upload_path)
      )
    end

    factory :archived_document do
      archived { true }
    end

  end
end
