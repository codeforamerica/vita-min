# == Schema Information
#
# Table name: doc_assessments
#
#  id                :bigint           not null, primary key
#  error             :text
#  prompt_version    :string           default("v1"), not null
#  raw_response_json :jsonb            not null
#  result_json       :jsonb            not null
#  status            :string           default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_id       :bigint           not null
#  input_blob_id     :bigint           not null
#  model_id          :string
#
# Indexes
#
#  index_doc_assessments_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
require "rails_helper"

RSpec.describe DocAssessment, type: :model do
  describe "#smart_scan_status" do
    let(:document) { create(:document) }

    context "when matches_doc_type_verdict is 'pass'" do
      let(:assessment) do
        described_class.new(
          document: document,
          result_json: { "matches_doc_type_verdict" => "pass" }
        )
      end

      it "returns 'pass'" do
        expect(assessment.smart_scan_status).to eq("pass")
      end
    end

    context "when matches_doc_type_verdict is present but not 'pass'" do
      let(:assessment) do
        described_class.new(
          document: document,
          result_json: { "matches_doc_type_verdict" => "fail" }
        )
      end

      it "returns 'fail'" do
        expect(assessment.smart_scan_status).to eq("fail")
      end
    end

    context "when matches_doc_type_verdict is nil" do
      let(:assessment) do
        described_class.new(
          document: document,
          result_json: {}
        )
      end

      it "returns 'attention'" do
        expect(assessment.smart_scan_status).to eq("attention")
      end
    end

    context "when result_json itself is nil" do
      let(:assessment) do
        described_class.new(
          document: document,
          result_json: nil
        )
      end

      it "returns 'attention'" do
        expect(assessment.smart_scan_status).to eq("attention")
      end
    end
  end
end
