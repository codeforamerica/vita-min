require "rails_helper"

RSpec.describe RequestedDocumentUploadForm do
  let(:intake) { create(:intake) }
  let(:documents_request) { create(:documents_request) }

  describe "validations" do
    context "when valid params" do
      let(:valid_params) do
        {
            upload: fixture_file_upload("test-pattern.png")
        }
      end

      it "is valid" do
        form = described_class.new(documents_request, valid_params)

        expect(form).to be_valid
      end
    end

    context "when uploading a file whose file extension is disallowed" do
      let(:params) { { upload: fixture_file_upload("test-pattern.html") } }

      it "is not valid" do
        form = described_class.new(documents_request, params)

        expect(form).not_to be_valid
        expect(form.errors.messages[:upload].first).to include "Please upload a valid document type. Accepted types include"
      end
    end

    context "when uploading a nil file" do
      let(:params) { { upload: nil } }

      it "is not valid" do
        form = described_class.new(documents_request, params)

        expect(form).not_to be_valid
        expect(form.errors.messages[:upload]).to include "Can't be blank."
      end
    end

    context "when the document model has errors" do
      let(:params) { { upload: fixture_file_upload("test-pattern.png") } }
      let!(:fake_document) { build(:document) }

      before do
        allow(fake_document).to receive(:valid?).and_return(false)
        fake_errors = ActiveModel::Errors.new(nil)
        fake_errors.add(:upload, "Example error")
        allow(fake_document).to receive(:errors).and_return(fake_errors)
        allow(Document).to receive(:new).and_return(fake_document)
      end

      it "makes the form invalid and copies the errors onto the form" do
        form = described_class.new(documents_request, params)

        expect(form).not_to be_valid
        expect(form.errors[:upload]).to eq(["Example error"])
      end
    end

    context "when the document is missing" do
      let(:params) { { } }

      it "is not valid" do
        form = described_class.new(documents_request, params)

        expect(form).not_to be_valid
        expect(form.errors[:upload]).to include "Can't be blank."
      end
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
            upload: fixture_file_upload("test-pattern.png")
        }
      end

      it "creates a new document" do
        expect {
          described_class.new(documents_request, params).save
        }.to change { documents_request.reload.documents.count }.by(1)
        doc = Document.last
        expect(doc.upload.blob.filename.to_s).to eq("test-pattern.png")
        expect(doc.upload.download).to eq(File.binread("spec/fixtures/files/test-pattern.png"))
        expect(doc.upload.content_type).to eq "image/png"
      end
    end

    context "with non-utf-8 filename" do
      # Clients have uploaded files with non-utf8 characters in filenames
      let(:file_upload) { fixture_file_upload("test-pattern.png") }

      let(:params) do
        {
            upload: file_upload
        }
      end

      before do
        allow(file_upload).to receive(:original_filename).and_return "Skip a non-utf8\xc2 char.png"
      end

      it "creates a new document, skipping invalid characters in the filename" do
        expect {
          described_class.new(documents_request, params).save
        }.to change { documents_request.reload.documents.count }.by(1)
        expect(Document.last.upload.blob.filename.to_s).to eq("Skip a non-utf8 char.png")
      end
    end
  end
end
