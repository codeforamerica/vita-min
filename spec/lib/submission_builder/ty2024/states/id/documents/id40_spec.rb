require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id40, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "single filer" do
      let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }
      before do
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_19).and_return(2000)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_20).and_return(200)
      end

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "SINGLE"
        expect(xml.at("PrimeExemption").text).to eq "1"
        expect(xml.at("TotalExemption").text).to eq "1"
        expect(xml.at("FederalAGI").text).to eq "10000"
        # fed agi(32351) - [fed_taxable_ssb(5627) + total_qualifying_dependent_care_expenses(2000)] = 24724
        expect(xml.at("StateTotalAdjustedIncome").text).to eq "10000"
        expect(xml.at("StandardDeduction").text).to eq "13850"
        expect(xml.at("TaxableIncomeState").text).to eq "2000"
        expect(xml.at("StateIncomeTax").text).to eq "200"
      end

      context "primary over 65, blind, claimed as dependent" do
        context "when true" do
          before do
            intake.direct_file_data.primary_over_65 = "X"
            intake.direct_file_data.primary_blind = "X"
            intake.direct_file_data.primary_claim_as_dependent = "X"
          end

          it "fills a 1" do
            expect(xml.at("PrimeOver65").text).to eq "1"
            expect(xml.at("PrimeBlind").text).to eq "1"
            expect(xml.at("ClaimedAsDependent").text).to eq "1"
          end
        end

        context "when false" do
          before do
            intake.direct_file_data.primary_over_65 = ""
            intake.direct_file_data.primary_blind = ""
            intake.direct_file_data.primary_claim_as_dependent = ""
          end

          it "does not have the node" do
            expect(xml.at("PrimeOver65")).to be_nil
            expect(xml.at("PrimeBlind")).to be_nil
            expect(xml.at("ClaimedAsDependent")).to be_nil
          end
        end
      end
    end

    context "married filing jointly" do
      let(:intake) { create(:state_file_id_intake, :mfj_filer_with_json) }

      before do
        intake.direct_file_data.spouse_claimed_dependent = false
      end

      it "correctly fills answers" do
        expect(xml.at("FilingStatus").text).to eq "JOINT"
        expect(xml.at("PrimeExemption").text).to eq "1"
        expect(xml.at("SpouseExemption").text).to eq "1"
        expect(xml.at("TotalExemption").text).to eq "2"
      end

      context "spouse over 65" do
        context "when true" do
          before do
            intake.direct_file_data.spouse_over_65 = "X"
            intake.direct_file_data.spouse_blind = "X"
          end

          it "fills a 1" do
            expect(xml.at("SpouseOver65").text).to eq "1"
            expect(xml.at("SpouseBlind").text).to eq "1"
          end
        end

        context "when false" do
          before do
            intake.direct_file_data.spouse_over_65 = ""
            intake.direct_file_data.spouse_blind = ""
          end

          it "does not have the node" do
            expect(xml.at("SpouseOver65")).to be_nil
            expect(xml.at("SpouseBlind")).to be_nil
          end
        end
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

      it "fills out dependent information" do
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

    context "PermanentBuildingFund" do
      context "when a client is not blind has filing requirements and does not receive public assistance" do
        before do
          intake.direct_file_data.total_income_amount = 40000
          intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
          intake.received_id_public_assistance = "no"
        end

        it "fills out StateUseTax field with calculated value" do
          expect(xml.at("PermanentBuildingFund").text).to eq '10'
        end
      end

      context "when a client is blind" do
        before do
          intake.direct_file_data.total_income_amount = 40000
          intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
          intake.direct_file_data.primary_blind = "X"
          intake.received_id_public_assistance = "no"
        end

        it "fills out StateUseTax field with 0" do
          expect(xml.at("PermanentBuildingFund").text).to eq '0'
        end
      end
    end

    context "grocery credit" do
      let(:intake) { create(:state_file_id_intake, :mfj_filer_with_json) }

      context "when there is a grocery credit amount" do
        it "fills out line 43" do
          expect(xml.at("WorksheetGroceryCredit").text.to_i).to eq 240
          expect(xml.at("GroceryCredit").text.to_i).to eq 240
          expect(xml.at("DonateGroceryCredit").text).to eq("false")
        end
      end

      context "when the filer chooses to donate their grocery credit" do
        before do
          intake.donate_grocery_credit_yes!
        end

        it "fills out the line 43 donate checkbox" do
          expect(xml.at("WorksheetGroceryCredit").text.to_i).to eq 240
          expect(xml.at("GroceryCredit").text.to_i).to eq 0
          expect(xml.at("DonateGroceryCredit").text).to eq("true")
        end
      end
    end

    context "with income forms" do
      # Miranda has two W-2s with state tax withheld amount (507, 1502) and two 1099Rs with no state tax withheld
      let(:intake) {
        create(:state_file_id_intake,
               :with_w2s_synced,
               raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
      }

      it "should fill out the state tax withheld amount" do
        expect(xml.at("TaxWithheld").text).to eq "2009"
      end
    end
  end
end