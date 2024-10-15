require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::MdReturnXml, required_schema: "md" do
  describe '.build' do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:instance) {described_class.new(submission)}
    let(:build_response) { instance.build }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "502R" do
      let(:intake) { create(:state_file_md_intake)}

      context "when taxable pensions/IRAs/annuities are present" do
        before do
          intake.direct_file_data.fed_taxable_pensions = 1
        end

        it "attaches a 502R" do
          expect(xml.at("Form502R")).to be_present
          expect(instance.pdf_documents).to be_any { |included_document|
            included_document.pdf == PdfFiller::Md502RPdf
          }
        end
      end

      context "when taxable pensions/IRAs/annuities are not present" do
        before do
          intake.direct_file_data.fed_taxable_pensions = 0
        end

        it "does not attach a 502R" do
          expect(xml.at("Form502R")).not_to be_present
          expect(instance.pdf_documents).not_to be_any { |included_document|
            included_document.pdf == PdfFiller::Md502RPdf
          }
        end
      end
    end

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
    end

  end
end