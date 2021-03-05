require 'rails_helper'

describe Consent do
  describe "#update_or_create_optional_consent" do
    let(:consent) { create(:consent, client: create(:client)) }

    before do
      example_pdf = Tempfile.new("example.pdf")
      example_pdf.write("example pdf contents")
      allow(OptionalConsentPdf).to receive(:new).and_return(double(output_file: example_pdf))
    end

    context "when there is not an existing optional consent document" do
      it "creates an optional consent document" do
        expect { consent.update_or_create_optional_consent_pdf }.to change(Document, :count).by(1)

        doc = Document.last
        expect(doc.display_name).to eq("optional-consent-2021.pdf")
        expect(doc.document_type).to eq(DocumentTypes::OptionalConsentForm.key)
        expect(doc.client).to eq(consent.client)
        expect(doc.upload.content_type).to eq("application/pdf")
      end
    end

    context "when there is an existing optional consent document" do
      let!(:document) { consent.update_or_create_optional_consent_pdf }

      it "updates the existing document with a regenerated form" do
        expect {
          expect {
            consent.update_or_create_optional_consent_pdf
          }.not_to change(Document, :count)
        }.to change{document.reload.updated_at}
        expect(document.display_name).to eq "optional-consent-2021.pdf"
      end
    end
  end
end
