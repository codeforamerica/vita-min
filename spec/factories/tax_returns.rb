# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  current_state       :string           default("intake_before_consent")
#  filing_status       :integer
#  filing_status_note  :text
#  internal_efile      :boolean          default(FALSE), not null
#  is_ctc              :boolean          default(FALSE)
#  is_hsa              :boolean
#  primary_signature   :string
#  primary_signed_at   :datetime
#  primary_signed_ip   :inet
#  ready_for_prep_at   :datetime
#  service_type        :integer          default("online_intake")
#  spouse_signature    :string
#  spouse_signed_at    :datetime
#  spouse_signed_ip    :inet
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assigned_user_id    :bigint
#  client_id           :bigint           not null
#
# Indexes
#
#  index_tax_returns_on_assigned_user_id    (assigned_user_id)
#  index_tax_returns_on_client_id           (client_id)
#  index_tax_returns_on_current_state       (current_state)
#  index_tax_returns_on_year                (year)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
FactoryBot.define do
  factory :tax_return do
    client { build(:client, intake: build(:intake)) }
    filing_status { "single" }
    transient do
      metadata { {} }
    end

    TaxReturnStateMachine.states.each do |state|
      trait state.to_sym do
        after :build do |tax_return, evaluator|
          tax_return.tax_return_transitions << build(:tax_return_transition, state, tax_return: tax_return, metadata: evaluator.metadata)
        end

        after :create do |tax_return, evaluator|
          tax_return.tax_return_transitions.each(&:save)
          tax_return.reload
          tax_return.update_columns(current_state: state)
          SearchIndexer.refresh_filterable_properties([tax_return.client_id])
        end
      end
    end

    factory :gyr_tax_return do
      year { MultiTenantService.new(:gyr).current_tax_year }
    end

    factory :ctc_tax_return do
      year { MultiTenantService.new(:ctc).current_tax_year }
      client { build(:client, intake: build(:ctc_intake)) }
      is_ctc { true }
    end

    trait :ready_to_sign do
      review_signature_requested
      after(:build) do |tax_return|
        create(:document,
               client: tax_return.client,
               tax_return: tax_return,
               upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"),
               document_type: DocumentTypes::UnsignedForm8879.key
        )
      end
    end

    trait :ctc do
      year { 2021 }
      client { build(:ctc_client, intake: build(:ctc_intake, :with_contact_info, :with_address, :with_dependents, :with_ssns, :with_bank_account, :primary_consented, dependent_count: 3)) }
      is_ctc { true }
      internal_efile { true }
    end

    trait :with_final_tax_doc do
      after(:build) do |tax_return|
        create(:document,
               client: tax_return.client,
               tax_return: tax_return,
               upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"),
               document_type: DocumentTypes::FinalTaxDocument.key
        )
      end
    end

    trait :ready_to_file_solo do
      file_ready_to_file
      primary_signature { client.legal_name }
      primary_signed_at { DateTime.current }
      primary_signed_ip { IPAddr.new }
      after(:build) do |tax_return|
        create :document,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"),
               document_type: DocumentTypes::CompletedForm8879.key
      end
    end

    trait :ready_to_file_joint do
      file_ready_to_file
      primary_signature { client.legal_name }
      primary_signed_at { DateTime.current }
      primary_signed_ip { IPAddr.new }
      spouse_signature { client.spouse_legal_name }
      spouse_signed_at { DateTime.current }
      spouse_signed_ip { IPAddr.new }
      after(:build) do |tax_return|
        create :document,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"),
               document_type: DocumentTypes::CompletedForm8879.key
      end
    end

    trait :primary_has_signed do
      primary_signed_at { DateTime.now }
      primary_signed_ip { IPAddr.new }
      primary_signature { "Primary Taxpayer" }
    end
  end
end
