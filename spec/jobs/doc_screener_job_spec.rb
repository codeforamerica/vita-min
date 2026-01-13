require "rails_helper"

RSpec.describe DocScreenerJob, type: :job do
  let(:document) { create :document, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }
  let(:document_id) { document.id }
  let(:result_json) { { "confidence" => 0.99 }.to_json }
  let(:raw_response_json) { { "raw" => "response" }.to_json }

  before do
    # feature flag disabled by default
    allow(Flipper).to receive(:enabled?).with(:disable_ai_doc_screener).and_return(false)
    allow(BedrockDocScreener).to receive(:screen_document!).and_return([result_json, raw_response_json])
  end

  context "when disable_ai_doc_screener enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:disable_ai_doc_screener).and_return(true)
    end

    it "does not call doc screener or create an assessment" do
      expect(BedrockDocScreener).not_to receive(:screen_document!)

      expect { described_class.perform_now(document_id) }.not_to change(DocAssessment, :count)
    end
  end

  context "when the document has no attachment" do
    let(:document) do
      create(:document).tap do |doc|
        doc.upload.purge
      end
    end

    it "returns early" do
      expect(BedrockDocScreener).not_to have_received(:screen_document!)
      expect { described_class.perform_now(document_id) }.not_to change(DocAssessment, :count)
    end
  end

  context "when there is no existing assessment" do
    it "creates an assessment, marks it processing, runs screener, then completes it" do
      expect do
        described_class.perform_now(document_id)
      end.to change(DocAssessment, :count).by(1)

      assessment = DocAssessment.last
      expect(assessment.document_id).to eq(document.id)
      expect(assessment.prompt_version).to eq(BedrockDocScreener::PROMPT_VERSION)
      expect(assessment.input_blob_id).to eq(document.upload.blob_id)
      expect(assessment.status).to eq("complete")
      expect(assessment.model_id).to eq(BedrockDocScreener::MODEL_ID)
      expect(assessment.result_json).to eq(result_json)
      expect(assessment.raw_response_json).to eq(raw_response_json)

      expect(BedrockDocScreener).to have_received(:screen_document!).with(document: document)
    end
  end

  context "when an existing assessment is not complete" do
    let!(:existing_assessment) do
      create(
        :doc_assessment,
        document: document,
        prompt_version: BedrockDocScreener::PROMPT_VERSION,
        input_blob_id: document.upload.blob_id,
        status: "failed",
        error: "error message here bla bla"
      )
    end

    it "reuses the existing assessment instead of creating a new one" do
      expect {
        described_class.perform_now(document_id)
      }.not_to change(DocAssessment, :count)

      expect(existing_assessment.reload.status).to eq("complete")
      expect(existing_assessment.model_id).to eq(BedrockDocScreener::MODEL_ID)
      expect(existing_assessment.error).to be_nil
      expect(existing_assessment.result_json).to eq(result_json)
      expect(existing_assessment.raw_response_json).to eq(raw_response_json)
    end
  end

  context "when an existing assessment is complete" do
    let!(:complete_assessment) do
      create(
        :doc_assessment,
        document: document,
        prompt_version: BedrockDocScreener::PROMPT_VERSION,
        input_blob_id: document.upload.blob_id,
        status: "complete",
        model_id: BedrockDocScreener::MODEL_ID,
        result_json: "{}",
        raw_response_json: "{}"
      )
    end

    it "creates a new assessment instead of reusing the complete one" do
      expect {
        described_class.perform_now(document_id)
      }.to change(DocAssessment, :count).by(1)

      new_assessment = DocAssessment.order(:created_at).last
      expect(new_assessment.id).not_to eq(complete_assessment.id)

      expect(new_assessment.status).to eq("complete")
      expect(new_assessment.document_id).to eq(document.id)
      expect(new_assessment.prompt_version).to eq(BedrockDocScreener::PROMPT_VERSION)
      expect(new_assessment.input_blob_id).to eq(document.upload.blob_id)
      expect(new_assessment.model_id).to eq(BedrockDocScreener::MODEL_ID)
      expect(new_assessment.result_json).to eq(result_json)
      expect(new_assessment.raw_response_json).to eq(raw_response_json)
    end
  end

  context "when the screener raises an error" do
    let(:error) { StandardError.new("boom") }

    before do
      allow(BedrockDocScreener).to receive(:screen_document!).and_raise(error)
    end

    it "marks the assessment as failed and re-raises the error" do
      expect do
        expect { described_class.perform_now(document_id) }.to raise_error(StandardError, "boom")
      end.to change(DocAssessment, :count).by(1)

      assessment = DocAssessment.last
      expect(assessment.status).to eq("failed")
      expect(assessment.error).to include("StandardError: boom")
    end
  end
end
