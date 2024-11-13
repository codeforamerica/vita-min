require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::MdReturnXml, required_schema: "md" do
  describe ".build" do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:instance) {described_class.new(submission)}
    let(:build_response) { instance.build }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }
    let(:intake) { create(:state_file_md_intake)}


    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
    end

    context "When there are 1099gs present" do
      let(:builder_class) { StateFile::StateInformationService.submission_builder_class(:md) }
      let(:intake) { create(:state_file_md_intake) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let!(:form1099g_1) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }
      let!(:form1099g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 200) }

      it "builds all MD1099gs from intake" do
        xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

        expect(xml.css("MD1099G").count).to eq 2
      end
    end

    context "attached documents" do
      it "includes documents that are always attached" do
        expect(xml.document.at('ReturnDataState Form502')).to be_an_instance_of Nokogiri::XML::Element
        expect(xml.document.at('ReturnDataState Form502CR')).to be_an_instance_of Nokogiri::XML::Element
        expect(instance.pdf_documents).to be_any { |included_documents|
          included_documents.pdf = PdfFiller::Md502CrPdf
        }
        expect(instance.pdf_documents).to be_any { |included_documents|
          included_documents.pdf = PdfFiller::MdEl101Pdf
        }
      end

      context "502B" do
        context "when there are dependents" do
          let!(:dependent) { create :state_file_dependent, dob: StateFileDependent.senior_cutoff_date + 20.years, intake: intake }

          it "includes the document" do
            expect(xml.document.at('ReturnDataState Form502B')).to be_an_instance_of Nokogiri::XML::Element
          end
        end

        context "when there are no dependents" do
          it "does not include the document" do
            expect(xml.document.at('ReturnDataState Form502B')).to be_nil
          end
        end
      end

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

      context "502CR" do
        it "attaches a 502CR" do
          expect(xml.at("Form502CR")).to be_present
          expect(instance.pdf_documents).to be_any { |included_documents|
            included_documents.pdf = PdfFiller::Md502CrPdf
          }
        end
      end
    end
  end
end
