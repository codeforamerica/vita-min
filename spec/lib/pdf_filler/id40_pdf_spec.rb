require 'rails_helper'

RSpec.describe PdfFiller::Id40Pdf do
  include PdfSpecHelper

  let!(:intake) {
    create(:state_file_id_intake,
           :single_filer_with_json, # includes phone number data
           primary_esigned: "yes",
           primary_esigned_at: DateTime.now)
  }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(described_class.new(submission).output_file.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "when filer signed submission agreement" do
      it 'sets signature date field to the correct value' do
        expect(pdf_fields["DateSign 2"]).to eq DateTime.now.strftime("%m-%d-%Y")
        expect(pdf_fields["TaxpayerPhoneNo"]).to eq "2085551234"
      end
    end
    
    context "pulling fields from xml" do
      let(:intake) {
        create(:state_file_id_intake,
               :single_filer_with_json,
               primary_first_name: "Ida",
               primary_last_name: "Idahoan",
              )
      }

      it 'sets static fields to the correct values' do
        expect(pdf_fields['YearBeginning']).to eq Rails.configuration.statefile_current_tax_year.to_s
        expect(pdf_fields['YearEnding']).to eq Rails.configuration.statefile_current_tax_year.to_s
      end

      it "sets other fields to the correct values" do
        expect(pdf_fields['FirstNameInitial']).to eq 'Ida'
        expect(pdf_fields['LastName']).to eq 'Idahoan'
        expect(pdf_fields['SSN']).to eq '400000012'
        expect(pdf_fields['CurrentMailing']).to eq '321 Creek Drive'
        expect(pdf_fields['City']).to eq 'Wallace'
        expect(pdf_fields['StateAbbrv']).to eq 'ID'
        expect(pdf_fields['ZIPcode']).to eq '83873'

        expect(pdf_fields['FilingStatusSingle']).to eq 'Yes'
        expect(pdf_fields['FilingStatusMarriedJoint']).to eq 'Off'
        expect(pdf_fields['FilingStatusMarriedSeparate']).to eq 'Off'
        expect(pdf_fields['FilingStatusHead']).to eq 'Off'
        expect(pdf_fields['SpouseDeceased']).to eq 'Off'

        expect(pdf_fields['6aYourself']).to eq '1'
        expect(pdf_fields['6bSpouse']).to eq ''
        expect(pdf_fields['6cDependents']).to eq ''
        expect(pdf_fields['6dTotalHousehold']).to eq '1'
      end

      context "with dependents" do
        before do
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "One", ssn: "123456789", dob: Date.new(2010, 1, 1))
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Two", ssn: "987654321", dob: Date.new(2012, 2, 2))
        end

        it "sets dependent fields correctly" do
          expect(pdf_fields['6cDependent1First']).to eq 'Child'
          expect(pdf_fields['6cDependent1Last']).to eq 'One'
          expect(pdf_fields['6cDependent1SSN']).to eq '123456789'
          expect(pdf_fields['6cDependent1Birthdate']).to eq '01/01/2010'

          expect(pdf_fields['6cDependent2First']).to eq 'Child'
          expect(pdf_fields['6cDependent2Last']).to eq 'Two'
          expect(pdf_fields['6cDependent2SSN']).to eq '987654321'
          expect(pdf_fields['6cDependent2Birthdate']).to eq '02/02/2012'

          expect(pdf_fields['6cDependents']).to eq '2'
          expect(pdf_fields['6dTotalHousehold']).to eq '3'
          pdf_fields['PermanentBuildingFund'].to eq '10.00'
        end
      end
    end

    context "married filing jointly" do
      let(:intake) {
        create(:state_file_id_intake,
               :mfj_filer_with_json,
               spouse_first_name: "Spida",
               spouse_last_name: "Spidahoan")
      }

      context "with a spouse that is claimed as a dependent" do
        it "sets spouse fields correctly" do
          expect(pdf_fields['SpouseFirstNameInitial']).to eq 'Spida'
          expect(pdf_fields['SpouseLastName']).to eq 'Spidahoan'
          expect(pdf_fields['SpouseSSN']).to eq '600000030'
          expect(pdf_fields['FilingStatusMarriedJoint']).to eq 'Yes'
          expect(pdf_fields['FilingStatusSingle']).to eq 'Off'
          expect(pdf_fields['FilingStatusMarriedSeparate']).to eq 'Off'
          expect(pdf_fields['FilingStatusHead']).to eq 'Off'
          expect(pdf_fields['SpouseDeceased']).to eq 'Off'
          expect(pdf_fields['6bSpouse']).to eq '' # Spouse claimed as dependent, so not counted here
          expect(pdf_fields['6dTotalHousehold']).to eq '1'
        end
      end

      context "with a spouse that is not claimed as a dependent" do
        before do
          submission.data_source.direct_file_data.spouse_claimed_dependent = ""
        end

        it "sets spouse fields correctly" do
          expect(pdf_fields['6bSpouse']).to eq '1' # Spouse not claimed as dependent, so counted here
          expect(pdf_fields['6dTotalHousehold']).to eq '2'
        end
      end

      # context "with a spouse who is blind" do
      #   before do
      #     submission.data_source.direct_file_data.spouse_blind = "yes"
      #   end
      #   it "sets permanent building fund correctly" do
      #     expect(pdf_fields['PermanentBuildingFund']).to eq '0'
      #   end
      # end
    end

    describe "filing status fields" do
      context "when filing status is married filing separately" do
        let(:intake) { create(:state_file_id_intake, filing_status: "married_filing_separately") }

        it "sets the correct filing status field" do
          expect(pdf_fields['FilingStatusMarriedSeparate']).to eq 'Yes'
          expect(pdf_fields['FilingStatusSingle']).to eq 'Off'
          expect(pdf_fields['FilingStatusMarriedJoint']).to eq 'Off'
          expect(pdf_fields['FilingStatusHead']).to eq 'Off'
          expect(pdf_fields['SpouseDeceased']).to eq 'Off'
        end
      end

      context "when filing status is head of household" do
        let(:intake) { create(:state_file_id_intake, filing_status: "head_of_household") }

        it "sets the correct filing status field" do
          expect(pdf_fields['FilingStatusHead']).to eq 'Yes'
          expect(pdf_fields['FilingStatusSingle']).to eq 'Off'
          expect(pdf_fields['FilingStatusMarriedJoint']).to eq 'Off'
          expect(pdf_fields['FilingStatusMarriedSeparate']).to eq 'Off'
          expect(pdf_fields['SpouseDeceased']).to eq 'Off'
        end
      end

      context "when filing status is qualifying widow" do
        let(:intake) { create(:state_file_id_intake, filing_status: "qualifying_widow") }

        it "sets the correct filing status field" do
          expect(pdf_fields['SpouseDeceased']).to eq 'Yes'
          expect(pdf_fields['FilingStatusSingle']).to eq 'Off'
          expect(pdf_fields['FilingStatusMarriedJoint']).to eq 'Off'
          expect(pdf_fields['FilingStatusMarriedSeparate']).to eq 'Off'
          expect(pdf_fields['FilingStatusHead']).to eq 'Off'
        end
      end
    end

    describe "state use tax" do
      let(:intake) { create(:state_file_id_intake, has_unpaid_sales_use_tax: "yes", total_purchase_amount: 1200.50) }

      it "sets the correct filing status field" do
        expect(pdf_fields['OtherTaxesL29']).to eq '72'
      end
    end

    describe "tax withheld" do
      # Miranda has two W-2s with state tax withheld amount (507, 1502) and two 1099Rs with no state tax withheld
      let(:intake) {
        create(:state_file_id_intake,
               :with_w2s_synced,
               raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
      }

      it "sets the correct tax withheld field" do
        expect(pdf_fields['PymntOtherCreditL46']).to eq '2009'
      end
    end
  end
end
