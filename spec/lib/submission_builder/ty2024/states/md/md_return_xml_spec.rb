require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::MdReturnXml, required_schema: "md" do
  describe '.build' do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
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

    context "Income section" do
      let(:direct_file_xml) { StateFile::XmlReturnSampleService.new.read('md_zeus_two_w2s') }
      let(:intake) { create(:state_file_md_intake, raw_direct_file_data: direct_file_xml)}

      context "when all relevant values are present in the DF XML" do
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
          intake.direct_file_data.fed_taxable_pensions = 100
          expect(xml.at("Form502 Income TaxablePensionsIRAsAnnuities").text.to_i).to eq(intake.direct_file_data.fed_taxable_pensions)
        end

        context "when interest sums to greater than 11600" do
          it "includes the indicator" do
            intake.direct_file_data.fed_taxable_income = 11_599
            intake.direct_file_data.fed_tax_exempt_interest = 2

            expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("X")
          end
        end

        context "when interest sums to less than 11600" do
          it "doesn't include the indicator" do
            intake.direct_file_data.fed_taxable_income = 11_599
            intake.direct_file_data.fed_tax_exempt_interest = 1

            expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("")
          end
        end
      end

      context "when some relevant values are missing from the DF XML" do
        it "populates the Income section correctly" do
          expect(xml.at("Form502 Income FederalAdjustedGrossIncome").text.to_i).to eq(intake.direct_file_data.fed_agi)
          expect(xml.at("Form502 Income WagesSalariesAndTips").text.to_i).to eq(intake.direct_file_data.fed_wages_salaries_tips)
          expect(xml.at("Form502 Income EarnedIncome").text.to_i).to eq(intake.direct_file_data.fed_wages_salaries_tips)
          expect(xml.at("Form502 Income TaxablePensionsIRAsAnnuities").text.to_i).to eq(0)
          expect(xml.at("Form502 Income InvestmentIncomeIndicator").text).to eq("")
        end
      end
    end
  end
end