require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::IdReturnXml, required_schema: "id" do
  describe '.build' do
    let(:intake) { create(:state_file_id_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:build_response) { described_class.build(submission) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
    end
  end

  describe '#supported_documents' do
    let(:intake) { create(:state_file_id_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:id_return_xml) { described_class.new(submission) }

    context 'with 4 or fewer dependents' do
      before do
        create_list(:state_file_dependent, 4, intake: intake)
      end

      it 'includes Id40 but not Id39r document' do
        docs = id_return_xml.send(:supported_documents)
        expect(docs).to include(
                          { xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id40, pdf: PdfFiller::Id40Pdf, include: true }
                        )
        expect(docs).to include(
                          { xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id39r, pdf: PdfFiller::Id39rPdf, include: false }
                        )
      end

      it 'does not include additional Id39r documents' do
        docs = id_return_xml.send(:supported_documents)
        additional_docs = docs.select { |doc| doc[:pdf] == PdfFiller::Id39rAdditionalDependentsPdf }
        expect(additional_docs).to be_empty
      end
    end
    context 'with 5 to 7 dependents' do
      before do
        create_list(:state_file_dependent, 6, intake: intake)
      end

      it 'includes Id40 and Id39r documents' do
        docs = id_return_xml.send(:supported_documents)
        expect(docs).to include(
                          { xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id40, pdf: PdfFiller::Id40Pdf, include: true },
                          { xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id39R, pdf: PdfFiller::Id39rPdf, include: true }
                        )
      end

      it 'does not include additional Id39r documents' do
        docs = id_return_xml.send(:supported_documents)
        additional_docs = docs.select { |doc| doc[:pdf] == PdfFiller::Id39rAdditionalDependentsPdf }
        expect(additional_docs).to be_empty
      end
    end

    context 'with more than 7 dependents' do
      before do
        create_list(:state_file_dependent, 10, intake: intake)
      end

      it 'includes Id40, Id39r, and additional Id39r documents' do
        docs = id_return_xml.send(:supported_documents)
        expect(docs).to include(
                          { xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id40, pdf: PdfFiller::Id40Pdf, include: true },
                          { xml: SubmissionBuilder::Ty2024::States::Id::Documents::Id39r, pdf: PdfFiller::Id39rPdf, include: true }
                        )

        additional_docs = docs.select { |doc| doc[:pdf] == PdfFiller::Id39rAdditionalDependentsPdf }
        expect(additional_docs.size).to eq(1)
        expect(additional_docs.first[:kwargs][:dependents].size).to eq(3)
      end
    end
  end
end
