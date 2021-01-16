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
    let!(:document) { create :document, document_type: DocumentTypes::UnsignedForm8879.key, tax_return: tax_return, client: client, uploaded_by: (create :user) }

    before do
      allow(tax_return).to receive(:filing_joint?).and_return false
      allow(WriteToPdfDocumentService).to receive(:new).and_return document_service_double
      allow(document_service_double).to receive(:tempfile_output).and_return Tempfile.new
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

    it "creates a signed document for the tax return" do
      expect {
        Sign8879Service.create(tax_return)
      }.to change(tax_return.documents, :count).by 1
      new_doc = Document.last
      expect(new_doc.document_type).to eq "Form 8879 (Signed)"
      expect(new_doc.display_name).to eq "Taxpayer Signed 2019 8879"
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
  end
end