require "rails_helper"

RSpec.describe DocumentTypeUploadForm do
  let(:intake) { create(:intake) }

  describe "validations" do
    context "when valid params" do
      let(:valid_params) do
        {
          document: fixture_file_upload("attachments/test-pattern.png")
        }
      end

      it "is valid" do
        form = described_class.new("Other", intake, valid_params)

        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:valid_params) do
        {
          document: fixture_file_upload("attachments/test-pattern.png")
        }
      end

      it "creates a new document" do
        document_type = "Other"
        expect {
          described_class.new(document_type, intake, valid_params).save
        }.to change { intake.reload.documents.count }.by(1)
        doc = Document.last
        expect(doc.upload.blob.filename.to_s).to eq("test-pattern.png")
        expect(doc.upload.download).to eq(File.binread("spec/fixtures/attachments/test-pattern.png"))
        expect(doc.upload.content_type).to eq "image/png"
      end
    end

    context "with non-utf-8 filename" do
      # Clients have uploaded files with non-utf8 characters in filenames
      let(:file_upload) { fixture_file_upload("attachments/test-pattern.png") }

      let(:valid_params) do
        {
          document: file_upload
        }
      end

      before do
        allow(file_upload).to receive(:original_filename).and_return "Skip a non-utf8\xc2 char.png"
      end

      it "creates a new document, skipping invalid characters in the filename" do
        document_type = "Other"
        expect {
          described_class.new(document_type, intake, valid_params).save
        }.to change { intake.reload.documents.count }.by(1)
        expect(Document.last.upload.blob.filename.to_s).to eq("Skip a non-utf8 char.png")
      end
    end
  end
end
