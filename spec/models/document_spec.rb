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

require "rails_helper"

describe Document do
  let(:attachment) { Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png") }

  describe "validations" do
    let(:document) { build :document }
    it "requires essential fields" do
      document = Document.new(document_type: nil)

      expect(document).to_not be_valid
      expect(document.errors).to include :document_type
      expect(document.errors).to include :upload
    end

    describe "#document_type" do
      it "expects document_type to be a valid choice" do
        document.document_type = "Book Report"
        expect(document).not_to be_valid
        expect(document.errors).to include :document_type
      end

      it "adds a human readable error if document type is blank" do
        document = Document.new(document_type: "")
        document.valid?
        expect(document.document_type).to be_blank
        expect(document.errors[:document_type]).to eq ["Can't be blank."]
      end

      context "document types not in DocumentTypes::ALL_TYPES" do
        it "allows 'Requested'" do
          document = Document.new(document_type: "Requested")
          document.valid?
          expect(document.errors).not_to include :document_type
        end

        it "allows 'F13614C / F15080 2020'" do
          document = Document.new(document_type: "F13614C / F15080 2020")
          document.valid?
          expect(document.errors).not_to include :document_type
        end
      end
    end

    describe "#tax_return_belongs_to_client" do
      let(:client){ create :client }
      let(:document) { build :document, client: client, tax_return: tax_return }

      context "with a tax return for a different client" do
        let(:tax_return) { create :tax_return }

        it "is not valid" do
          expect(document).not_to be_valid
          expect(document.errors).to include :tax_return
        end
      end

      context "with a tax return for the same client" do
        let(:tax_return) { create :tax_return, client: client }

        it "is valid" do
          expect(document).to be_valid
        end
      end

      context "with no tax return" do
        let(:tax_return) { nil }

        it "is valid" do
          expect(document).to be_valid
        end
      end
    end

    context "with a 0-byte upload" do
      let(:document) { build :document, upload_path: Rails.root.join("spec", "fixtures", "attachments", "zero-bytes.jpg") }
      it "rejects the file as invalid" do
        expect(document).not_to be_valid
        expect(document.errors).to include :upload
      end
    end

    describe "#file_type" do
      context "Form 8879 (Unsigned)" do
        context "not a PDF" do
          let(:document) { build :document, document_type: "Form 8879 (Unsigned)" }

          it "is not valid" do
            expect(document).not_to be_valid
            expect(document.errors[:upload]).to include "Form 8879 (Unsigned) must be a PDF file"
          end
        end

        context "a PDF" do
          let(:document) { build :document, document_type: "Form 8879 (Unsigned)", upload_path: Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf") }

          it "is valid" do
            expect(document).to be_valid
          end
        end
      end
    end
  end

  describe "before_save" do
    context "when created with a display_name and attachment" do
      let(:document) { build :document, display_name: "HumanReadable.jpg" }

      it "keeps the given display name" do
        document.save

        expect(document.display_name).to eq "HumanReadable.jpg"
      end
    end

    context "when there is no display name and there is an attachment" do
      let(:document) { build :document, upload_path: attachment }

      it "sets the default display name to the attachment filename" do
        document.save

        expect(document.display_name).to eq "test-pattern.png"
      end
    end
  end

  describe "after_create" do
    context "when the file extension is .heic" do
      it "creates a job to convert the file to jpg" do
        document = build :document, upload_path: Rails.root.join("spec", "fixtures", "attachments", "IMG_4851.HEIC")
        allow(HeicToJpgJob).to receive(:perform_later)

        document.save!

        expect(HeicToJpgJob).to have_received(:perform_later).with(document.id)
      end
    end

    context "when the file extension is not .heic" do
      it "does not create a job to covert the file to jpg" do
        document = build :document, upload_path: Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg")
        allow(HeicToJpgJob).to receive(:perform_later)

        document.save!

        expect(HeicToJpgJob).to_not have_received(:perform_later).with(document.id)
      end
    end
  end

  describe "creating a document" do
    let(:document) { build :document }
    let(:object) { document }

    context "when client is the uploader" do
      it_behaves_like "an incoming interaction" do
        let(:client) { create :client }
        let(:subject) { build :document, client: client, uploaded_by: client }
      end
    end

    context "when an user is the uploader" do
      it_behaves_like "an internal interaction" do
        let(:subject) { build :document, uploaded_by: (create :user) }
      end
    end

    context "when uploaded_by is nil" do
      it_behaves_like "an internal interaction" do
        let(:subject) { build :document, uploaded_by: nil }
      end
    end
  end

  describe "#convert_heic_upload_to_jpg!" do
    it "converts a heic attachment to jpg" do
      document = create :document, upload_path: Rails.root.join("spec", "fixtures", "attachments", "IMG_4851.HEIC")

      expect {
        document.convert_heic_upload_to_jpg!
      }.to (change{ document.upload.attachment.filename.extension }.from("HEIC").to("jpg")).and(
        change { document.reload.display_name }.from("IMG_4851.HEIC").to("IMG_4851.HEIC.jpg"))
    end
  end
end
