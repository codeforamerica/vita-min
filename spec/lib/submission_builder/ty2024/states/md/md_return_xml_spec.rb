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

    context "Income section" do
      let(:intake) { create(:state_file_md_intake)}

      context "when all relevant values are present in the DF XML" do

        before do
          intake.direct_file_data.fed_agi = 100
          intake.direct_file_data.fed_wages_salaries_tips = 101
          intake.direct_file_data.fed_taxable_pensions = 102
          intake.direct_file_data.fed_taxable_income = 11_599
          intake.direct_file_data.fed_tax_exempt_interest = 2
        end

        it "outputs AGI amount" do
          expect(xml.at("Form502 Income FederalAdjustedGrossIncome").text.to_i).to eq(intake.direct_file_data.fed_agi)
        end

        it "outputs wages, salaries and tips amount" do
          expect(xml.at("Form502 Income WagesSalariesAndTips").text.to_i).to eq(intake.direct_file_data.fed_wages_salaries_tips)
        end

        it "outputs earned income amount" do
          expect(xml.at("Form502 Income EarnedIncome").text.to_i).to eq(intake.direct_file_data.fed_wages_salaries_tips)
        end

        it "outputs taxable pensions, IRAs and annuities amount" do
          expect(xml.at("Form502 Income TaxablePensionsIRAsAnnuities").text.to_i).to eq(intake.direct_file_data.fed_taxable_pensions)
        end

        context "when interest sums to greater than 11600" do
          it "includes the indicator" do
            expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("X")
          end
        end

        context "when interest sums to less than 11600" do
          it "doesn't include the indicator" do
            intake.direct_file_data.fed_tax_exempt_interest = 1
            expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("")
          end
        end
      end

      context "when some relevant values are missing from the DF XML" do
        before do
          intake.direct_file_data.create_or_destroy_df_xml_node(:fed_agi, nil)
          intake.direct_file_data.create_or_destroy_df_xml_node(:fed_wages_salaries_tips, nil)
          intake.direct_file_data.create_or_destroy_df_xml_node(:fed_taxable_pensions, nil)
          intake.direct_file_data.create_or_destroy_df_xml_node(:fed_taxable_income, nil)
          intake.direct_file_data.create_or_destroy_df_xml_node(:fed_tax_exempt_interest, nil)
        end

        it "populates the Income section correctly" do
          expect(xml.at("Form502 Income FederalAdjustedGrossIncome").text.to_i).to eq(0)
          expect(xml.at("Form502 Income WagesSalariesAndTips").text.to_i).to eq(0)
          expect(xml.at("Form502 Income EarnedIncome").text.to_i).to eq(0)
          expect(xml.at("Form502 Income TaxablePensionsIRAsAnnuities").text.to_i).to eq(0)
          expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("")
        end
      end
    end
  end
end