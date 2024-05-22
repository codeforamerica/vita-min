# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  archived             :boolean          default(FALSE), not null
#  blur_score           :float
#  contact_record_type  :string
#  display_name         :string
#  document_type        :string           not null
#  person               :integer          default("unfilled"), not null
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
  let(:attachment) { Rails.root.join("spec", "fixtures", "files", "test-pattern.png") }

  describe "touch behavior" do
    context "when a document is created or is updated" do
      it "denormalizes document info onto the client" do
        intake = create :intake
        document = create :document, document_type: DocumentTypes::Selfie.key, intake: intake

        client = document.client.reload
        expect(client.filterable_percentage_of_required_documents_uploaded).to be_within(0.1).of(1 / 3.0)
        expect(client.filterable_number_of_required_documents_uploaded).to eq(1)
        expect(client.filterable_number_of_required_documents).to eq(3)
      end
    end
  end

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
        let(:tax_return) { create :gyr_tax_return }

        it "is not valid" do
          expect(document).not_to be_valid
          expect(document.errors).to include :tax_return_id
        end
      end

      context "with a tax return for the same client" do
        let(:tax_return) { create :gyr_tax_return, client: client }

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
      let(:document) { build :document, upload_path: Rails.root.join("spec", "fixtures", "files", "zero-bytes.jpg") }
      it "rejects the file as invalid" do
        expect(document).not_to be_valid
        expect(document.errors).to include :upload
      end
    end

    context "with a corrupted pdf upload" do
      let(:document) { build :document, document_type: DocumentTypes::UnsignedForm8879.key, upload_path: Rails.root.join("spec", "fixtures", "files", "corrupted.pdf") }
      it "rejects the file as invalid" do
        expect(document).not_to be_valid
        expect(document.errors).to include :upload
      end
    end

    describe "#file_type" do
      let(:client) { create :client }
      let(:tax_return) { build :gyr_tax_return, client: client }

      context "Form 8879 (Unsigned)" do
        context "not a PDF" do
          let(:document) { build :document, document_type: DocumentTypes::UnsignedForm8879.key, client: client, tax_return: tax_return }

          it "is not valid" do
            expect(document).not_to be_valid
            expect(document.errors[:upload]).to include "Form 8879 (Unsigned) must be a PDF file"
          end
        end

        context "a PDF" do
          let(:document) { build :document, document_type: DocumentTypes::UnsignedForm8879.key, client: client, tax_return: tax_return, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }

          it "is valid" do
            expect(document).to be_valid
          end
        end
      end
    end

    describe "#tax_return" do
      let(:client) { create :client }
      let(:final_tax_doc) { build :document, document_type: DocumentTypes::FinalTaxDocument.key, tax_return: tax_return, client: client }
      let(:unsigned_8879) { build :document, document_type: DocumentTypes::UnsignedForm8879.key, tax_return: tax_return, client: client, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }
      let(:w7) { build :document, document_type: DocumentTypes::FormW7.key, tax_return: tax_return, client: client, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }
      let(:w7coa) { build :document, document_type: DocumentTypes::FormW7Coa.key, tax_return: tax_return, client: client, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }

      context "with a tax return" do
        let(:tax_return) { create :gyr_tax_return, client: client }

        it "some document types are valid" do
          expect(final_tax_doc).to be_valid
          expect(unsigned_8879).to be_valid
        end

        it "some document types are invalid" do
          expect(w7).to be_invalid
          expect(w7coa).to be_invalid
        end
      end

      context "without a tax return" do
        let(:tax_return) { nil }

        it "some document types are valid" do
          expect(w7).to be_valid
          expect(w7coa).to be_valid
        end

        it "some document types are invalid" do
          expect(final_tax_doc).not_to be_valid
          expect(final_tax_doc.errors[:tax_return_id]).to include "Final Tax Document must be associated with a tax year."

          expect(unsigned_8879).not_to be_valid
          expect(unsigned_8879.errors[:tax_return_id]).to include "Form 8879 (Unsigned) must be associated with a tax year."
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
    include ActiveJob::TestHelper

    context "when the file extension is .heic" do
      before do
        allow(HeicToJpgJob).to receive(:perform_later).and_call_original
      end

      it "creates a job to convert the file to jpg and delays ActiveStorage::AnalyzeJob until then" do
        document = build :document, upload_path: Rails.root.join("spec", "fixtures", "files", "IMG_4851.HEIC")
        document.save!

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.map { |x| x["job_class"] }).to eq ["HeicToJpgJob"]
        perform_enqueued_jobs
        expect(HeicToJpgJob).to have_received(:perform_later).with(document.id)

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.map { |x| x["job_class"] }).to include("ActiveStorage::AnalyzeJob")
      end
    end

    context "when the file extension is not .heic" do
      it "does not create a job to covert the file to jpg and enqueues ActiveStorage::AnalyzeJob as normal" do
        document = build :document, upload_path: Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")
        allow(HeicToJpgJob).to receive(:perform_later)

        document.save!

        expect(HeicToJpgJob).to_not have_received(:perform_later).with(document.id)
        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.map { |x| x["job_class"] }).to eq ["ActiveStorage::AnalyzeJob"]
      end
    end
  end

  describe "creating a document" do
    let(:document) { build :document }
    let(:object) { document }

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
      document = create :document, upload_path: Rails.root.join("spec", "fixtures", "files", "IMG_4851.HEIC")

      expect {
        document.convert_heic_upload_to_jpg!
      }.to (change{ document.upload.attachment.filename.extension }.from("HEIC").to("jpg")).and(
        change { document.reload.display_name }.from("IMG_4851.HEIC").to("IMG_4851.HEIC.jpg"))
    end
  end
end
