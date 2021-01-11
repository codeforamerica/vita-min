require 'rails_helper'

describe Sign8879Service do
  subject { described_class.new(document) }

  context 'when the document type is not a Form 8879' do
    let(:document) { create :document, document_type: 'Not 8879' }
    it 'raises an error' do
      expect { subject }.to raise_error StandardError
    end
  end

  context "#sign_and_save" do
    let(:document_service_double) { double }
    let(:client) { create :client, intake: (create :intake, primary_first_name: "Primary", primary_last_name: "Taxpayer") }
    let(:tax_return) { create :tax_return, year: 2019, client: client }
    let!(:document) { create :document, document_type: DocumentTypes::Form8879.key, tax_return: tax_return, client: client }

    before do
      allow(WriteToDocumentService).to receive(:new).and_return document_service_double
      allow(document_service_double).to receive(:tempfile_output).and_return Tempfile.new
      allow(document_service_double).to receive(:write)
    end

    it "writes the primary taxpayers legal name to the document" do
      subject.sign_and_save
      expect(document_service_double).to have_received(:write).with(:primary_signature, "Primary Taxpayer")
    end

    it "writes today's date to the document, formatted mm/dd/yyyy" do
      subject.sign_and_save
      expect(document_service_double).to have_received(:write).with(:primary_signed_on, Date.today.strftime("%m/%d/%Y"))
    end

    it 'creates a signed document for the tax return' do
      expect { subject.sign_and_save }.to change(tax_return.documents, :count).by 1
      new_doc = Document.last
      expect(new_doc.document_type).to eq "Form 8879 (Signed)"
      expect(new_doc.display_name).to eq "Taxpayer Signed 2019 8879"
    end
  end
end