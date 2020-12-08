require "rails_helper"

describe DocumentPresenter do
  describe ".grouped_documents" do
    let(:intake) { create(:intake) }
    let(:duplicate_intake) { create(:intake) }
    let!(:employment_document_a) do
      create :document,
        document_type: "Employment",
        created_at: 2.day.ago,
        intake: intake
    end
    let!(:employment_document_b) do
      create :document,
        document_type: "Employment",
        created_at: 1.day.ago,
        intake: duplicate_intake
    end
    let!(:ssn_document) do
      create :document,
        document_type: "SSN or ITIN",
        created_at: 1.day.ago,
        intake: duplicate_intake
    end

    it "groups intake documents by document_type ordered by created_at" do
      document_groups = DocumentPresenter.grouped_documents([intake, duplicate_intake])
      expect(document_groups).to eq({
        "SSN or ITIN" => [ssn_document],
        "Employment" => [employment_document_a, employment_document_b]
      })
    end
  end

  describe "#time_ago" do
    let(:subject) { DocumentPresenter.new(document) }
    let(:document) { build(:document, created_at: 32.days.ago) }

    it "returns the when the document was created in human friendly words" do
      expect(subject.uploaded_ago).to eq("about 1 month ago")
    end

  end

  describe "#notes" do
    let(:document) { build(:document) }
    let(:byte_size) { 1000 }
    let(:content_type) { "image/jpeg" }
    let(:subject) { DocumentPresenter.new(document) }

    before do
      expect(subject).to receive(:byte_size).and_return(byte_size)
      expect(subject).to receive(:content_type).and_return(content_type)
    end

    context "normal sizes and extensions" do
      it "does not report anything" do
        expect(subject.notes).to be_empty
      end
    end

    context "uncommon situations" do
      let(:content_type) { "application/x-ms-dos-executable" }
      let(:byte_size) { 20_000_001 }

      it "reports the uncommon file type and byte size" do
        expect(subject.notes).to eq("Uncommon File Type, Large file size")
      end
    end
  end
end
