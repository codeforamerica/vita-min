require 'rails_helper'

describe Sign8879Service do
  describe ".create" do
    let(:document_service_double) { double }
    let(:intake_timezone) { 'America/New_York' }
    let(:client) { create :client,
                          intake: (create :intake,
                                          primary_first_name: "Primary",
                                          primary_last_name: "Taxpayer",
                                          timezone: intake_timezone
                          )
    }
    let(:time_signed_past_midnight_eastern) { DateTime.new(2023, 3, 14, 1, 0, 0, Time.now.in_time_zone('America/New_York').formatted_offset) }
    let(:tax_return) { create :tax_return,
                              year: 2019,
                              client: client,
                              primary_signature: "Primary Taxpayer",
                              primary_signed_ip: IPAddr.new,
                              primary_signed_at: time_signed_past_midnight_eastern
    }
    let!(:document) { create :document, document_type: DocumentTypes::UnsignedForm8879.key, tax_return: tax_return, client: client, created_at: DateTime.new(2023, 3, 10), uploaded_by: (create :user), upload_path:  Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }

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

    context "writing today's date (mm/dd/yyyy)" do
      context "when intake has a timezone" do
        it "uses the client's timezone to find the date" do
          Sign8879Service.create(tax_return)
          expect(document_service_double).to have_received(:write).with(:primary_signed_on, "03/14/2023")
        end
      end

      context "when we can't get the timezone" do
        let(:intake_timezone) { nil }

        it "uses pacific time" do
          Sign8879Service.create(tax_return)
          expect(document_service_double).to have_received(:write).with(:primary_signed_on, "03/13/2023 (Pacific)")
        end
      end
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
        tax_return.spouse_signed_at = time_signed_past_midnight_eastern
      end

      it "writes the spouses legal name and today's date in the intake's timezone to the document" do
        Sign8879Service.create(tax_return)

        expect(document_service_double).to have_received(:write).with(:spouse_signature, "Spouse Taxpayer")
        expect(document_service_double).to have_received(:write).with(:spouse_signed_on, "03/14/2023")
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
