require 'rails_helper'

describe Sign8879Service do
  describe ".create" do
    let(:document_service_double) { double }
    let(:client) { create :client,
                          intake: (create :intake,
                                          primary_first_name: "Primary",
                                          primary_last_name: "Taxpayer",
                                          timezone: "Central Time (US & Canada)"
                          )
    }
    let(:tax_return) { create :tax_return,
                              year: 2019,
                              client: client,
                              primary_signature: "Primary Taxpayer",
                              primary_signed_ip: IPAddr.new,
                              primary_signed_at: DateTime.current
    }
    let!(:document) { create :document, document_type: DocumentTypes::UnsignedForm8879.key, tax_return: tax_return, client: client, uploaded_by: (create :user), upload_path:  Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }

    before do
      allow(tax_return).to receive(:filing_jointly?).and_return false
      allow(WriteToPdfDocumentService).to receive(:new).and_return document_service_double
      allow(document_service_double).to receive(:tempfile_output).and_return File.open(Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"), "r")
      allow(document_service_double).to receive(:write)
    end

    it "writes the primary taxpayers legal name to the document" do
      Sign8879Service.create(tax_return)

      expect(document_service_double).to have_received(:write).with(:primary_signature, "Primary Taxpayer")
    end

    it "writes today's date to the document, formatted mm/dd/yyyy" do
      Sign8879Service.create(tax_return)
      expect(document_service_double).to have_received(:write).with(:primary_signed_on, DateTime.current.to_date.strftime("%m/%d/%Y"))
    end

    it "creates a signed document for the tax return, uploaded by the client" do
      expect {
        Sign8879Service.create(tax_return)
      }.to change(tax_return.documents.where(document_type: DocumentTypes::CompletedForm8879.key), :count).by 1
      new_doc = Document.last
      expect(new_doc.document_type).to eq "Form 8879 (Signed)"
      expect(new_doc.display_name).to eq "test-pdf.pdf (Signed)"
      expect(new_doc.uploaded_by).to eq client
    end

    context "there is a spouse signature" do
      before do
        tax_return.spouse_signature = "Spouse Taxpayer"
        tax_return.spouse_signed_ip = IPAddr.new
        tax_return.spouse_signed_at = DateTime.current
      end

      it "writes the spouses legal name to the document" do
        Sign8879Service.create(tax_return)

        expect(document_service_double).to have_received(:write).with(:spouse_signature, "Spouse Taxpayer")
      end
    end

    context "with multiple Unsigned 8879s for the tax year" do
      before do
        # create a second document
        create :document, document_type: DocumentTypes::UnsignedForm8879.key, tax_return: tax_return, client: client, uploaded_by: (create :user), upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
      end

      it "should create a completed 8879 for each unsigned 8879" do
        expect {
          Sign8879Service.create(tax_return)
        }.to change(tax_return.documents.where(document_type: DocumentTypes::CompletedForm8879.key), :count).by(2)
      end
    end
  end
end
