require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id40, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "single filer" do
      let(:intake) { create(:state_file_id_intake, filing_status: "single") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "SINGLE"
        expect(xml.at("PrimeExemption").text).to eq "1"
        expect(xml.at("TotalExemption").text).to eq "1"
      end
    end

    context "married filing jointly" do
      let(:intake) { create(:state_file_id_intake, filing_status: "married_filing_jointly") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "JOINT"
        expect(xml.at("PrimeExemption").text).to eq "1"
        expect(xml.at("SpouseExemption").text).to eq "1"
        expect(xml.at("TotalExemption").text).to eq "2"
      end
    end

    context "married filing separately" do
      let(:intake) { create(:state_file_id_intake, filing_status: "married_filing_separately") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "SEPART"
      end
    end

    context "head of household with dependents" do
      let(:intake) { create(:state_file_id_intake, filing_status: "head_of_household") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "HOH"
      end
    end

    context "qualifying widow" do
      let(:intake) { create(:state_file_id_intake, filing_status: "qualifying_widow") }

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "QWID"
      end
    end

    context "when there are dependents" do
      before do
        create(:state_file_dependent, intake: intake, first_name: "Gloria", last_name: "Hemingway", dob: Date.new(1920, 1, 1))
        create(:state_file_dependent, intake: intake, first_name: "Patrick", last_name: "Hemingway", dob: Date.new(1919, 1, 1))
        create(:state_file_dependent, intake: intake, first_name: "Jack", last_name: "Hemingway", dob: Date.new(1919, 1, 1))
      end

      it"fills out dependent information" do
        expect(xml.css('OtherExemption').text).to eq "3"
        expect(xml.css('DependentGrid').count).to eq 3

        expect(xml.css('DependentGrid')[0].at("DependentFirstName").text).to eq "Gloria"
        expect(xml.css('DependentGrid')[0].at("DependentLastName").text).to eq "Hemingway"
        expect(xml.css('DependentGrid')[0].at("DependentDOB").text).to eq "1920-01-01"

        expect(xml.css('DependentGrid')[1].at("DependentFirstName").text).to eq "Patrick"
        expect(xml.css('DependentGrid')[1].at("DependentLastName").text).to eq "Hemingway"
        expect(xml.css('DependentGrid')[1].at("DependentDOB").text).to eq "1919-01-01"

        expect(xml.css('DependentGrid')[2].at("DependentFirstName").text).to eq "Jack"
        expect(xml.css('DependentGrid')[2].at("DependentLastName").text).to eq "Hemingway"
        expect(xml.css('DependentGrid')[2].at("DependentDOB").text).to eq "1919-01-01"
      end
    end

    context "sales use tax" do
      context "when has unpaid sales use tax" do
        before do
          intake.update(has_unpaid_sales_use_tax: true, total_purchase_amount: 225)
        end

        it "fills out StateUseTax field with calculated value" do
          expect(xml.at("StateUseTax").text).to eq '14'
        end
      end

      context "when does not unpaid sales use tax" do
        before do
          intake.update(has_unpaid_sales_use_tax: false)
        end

        it "fills out StateUseTax field with 0" do
          expect(xml.at("StateUseTax").text).to eq '0'
        end
      end
    end
  end
end