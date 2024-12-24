require 'rails_helper'

RSpec.describe PdfFiller::Id40Pdf do
  include PdfSpecHelper

  let(:signature_date) { DateTime.now }
  let(:expected_signature_date_pdf_value) { signature_date.in_time_zone(StateFile::StateInformationService.timezone('id')).strftime("%m-%d-%Y") }
  let(:intake) {
    create(:state_file_id_intake,
           :single_filer_with_json, # includes phone number data
           primary_esigned: "yes",
           primary_esigned_at: signature_date)
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
        expect(pdf_fields["DateSign 2"]).to eq expected_signature_date_pdf_value
        expect(pdf_fields["TaxpayerPhoneNo"]).to eq "2085551234"
      end
    end

    context "pulling fields from xml" do
      let(:intake) {
        create(:state_file_id_intake,
               :single_filer_with_json,
               primary_first_name: "Ida",
               primary_last_name: "Idahoan",
               payment_or_deposit_type: :direct_deposit,
               routing_number: "123456789",
               account_number: "87654321",
               account_type: "checking"
        )
      }
      before do
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_19).and_return(2000)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_20).and_return(199.80)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:refund_or_owed_amount).and_return 500
      end

      it 'sets static fields to the correct values' do
        expect(pdf_fields['YearBeginning']).to be_nil
        expect(pdf_fields['YearEnding']).to be_nil
        expect(pdf_fields['TxCompL15']).to eq "0" # always 0, not in xml
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

        expect(pdf_fields['IncomeL7']).to eq '10000'
        expect(pdf_fields['IncomeL8']).to eq '0'
        expect(pdf_fields['IncomeL9']).to eq '10000'
        expect(pdf_fields['IncomeL10']).to eq '0'
        expect(pdf_fields['IncomeL11']).to eq '10000'
        expect(pdf_fields['L12aYourself ']).to eq 'Yes'
        expect(pdf_fields['L12aSpouse']).to eq 'Off'
        expect(pdf_fields['L12bYourself']).to eq 'Yes'
        expect(pdf_fields['L12bSpouse']).to eq 'Off'
        expect(pdf_fields['L12cDependent']).to eq 'Off'
        expect(pdf_fields['TxCompL16']).to eq '13850'
        expect(pdf_fields['TxCompL17']).to eq '2000' # same as L19
        expect(pdf_fields['TxCompL19']).to eq '2000'
        expect(pdf_fields['TxCompL20']).to eq '200'
        expect(pdf_fields['TxCompL20']).to eq '200'
        expect(pdf_fields['L21']).to eq '200'
        expect(pdf_fields['CreditsL23']).to eq '0'

        expect(pdf_fields['DirectDepositL57Route']).to eq "123456789"
        expect(pdf_fields['DirectDepositL57Acct']).to eq "87654321"
        expect(pdf_fields['DirectDepositChecking']).to eq "Yes"
        expect(pdf_fields['DirectDepositSavings ']).to eq "Off"
      end

      context "when client chooses savings" do
        before do
          intake.update(account_type: "savings")
        end

        it "sets savings checkbox, not the checking, and still has bank info" do
          expect(pdf_fields['DirectDepositL57Route']).to eq "123456789"
          expect(pdf_fields['DirectDepositL57Acct']).to eq "87654321"
          expect(pdf_fields['DirectDepositChecking']).to eq "Off"
          expect(pdf_fields['DirectDepositSavings ']).to eq "Yes"
        end
      end

      context "when claimed as dependent" do
        before do
          intake.direct_file_data.primary_claim_as_dependent = "X"
        end

        it "fills in the correct fields" do
          expect(pdf_fields['L12cDependent']).to eq 'Yes'
        end
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
          expect(pdf_fields['SpouseDeceased 2']).to eq 'Off'
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
          expect(pdf_fields['L12aYourself ']).to eq 'Off'
          expect(pdf_fields['L12aSpouse']).to eq 'Yes'
          expect(pdf_fields['L12bYourself']).to eq 'Off'
          expect(pdf_fields['L12bSpouse']).to eq 'Yes'
        end
      end

      context 'when spouse is deceased' do
        before do
          allow(intake).to receive(:spouse_deceased?).and_return(true)
        end

        it "checks the indicator" do
          expect(pdf_fields['SpouseDeceased 2']).to eq 'Yes'
        end
      end
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

    describe "permanent building fund tax" do
      context "with a filing requirement" do
        context "with a spouse who is blind" do
          let(:intake) {
            create(:state_file_id_intake,
                   :mfj_filer_with_json,
                   :spouse_blind,
                   :filing_requirement
            )
          }
          it "sets the correct filing status field" do
            expect(pdf_fields['OtherTaxesL32Check']).to eq 'Off'
          end
        end

        context "while blind" do
          let(:intake) {
            create(:state_file_id_intake,
                   :mfj_filer_with_json,
                   :primary_blind,
                   :filing_requirement
            )
          }
          it "sets the correct filing status field" do
            expect(pdf_fields['OtherTaxesL32Check']).to eq 'Off'
          end
        end

        context "when receiving public assistance" do
          let(:intake) {
            create(:state_file_id_intake,
                   :single_filer_with_json,
                   :filing_requirement,
                   received_id_public_assistance: :yes
            )
          }
          it "sets the correct filing status field" do
            expect(pdf_fields['OtherTaxesL32Check']).to eq 'Yes'
          end
        end

        context "when not receiving public assistance" do
          let(:intake) {
            create(:state_file_id_intake,
                   :single_filer_with_json,
                   :filing_requirement,
                   received_id_public_assistance: :no
            )
          }
          it "sets the correct filing status field" do
            expect(pdf_fields['OtherTaxesL32Check']).to eq 'Off'
          end
        end
      end

      context "without a filing requirement" do
        let(:intake) {
          create(:state_file_id_intake,
                 :single_filer_with_json,
                 :no_filing_requirement,
          )
        }
        it "sets the correct filing status field" do
          expect(pdf_fields['OtherTaxesL32Check']).to eq 'Off'
        end
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

    describe "credits" do
      before do
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_20).and_return 71
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_25).and_return 50
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_26).and_return 60
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_33).and_return 80
      end

      it "sets the correct values for the fields" do
        expect(pdf_fields['CreditsL25']).to eq '50'
        expect(pdf_fields['CreditsL26']).to eq '60'
        expect(pdf_fields['CreditsL27']).to eq '11'
        expect(pdf_fields['OtherTaxesL33']).to eq '80'
        expect(pdf_fields['DonationsL42']).to eq '80'
      end
    end

    describe "donation fields" do
      before do
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_34).and_return(50)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_35).and_return(30)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_36).and_return(20)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_37).and_return(40)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_38).and_return(25)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_39).and_return(10)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_40).and_return(60)
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_41).and_return(100)
      end

      it "sets the correct values for donation fields" do
        expect(pdf_fields['DonationsL34']).to eq '50'
        expect(pdf_fields['DonationsL35']).to eq '30'
        expect(pdf_fields['DonationsL36']).to eq '20'
        expect(pdf_fields['DonationsL37']).to eq '40'
        expect(pdf_fields['DonationsL38']).to eq '25'
        expect(pdf_fields['DonationsL39']).to eq '10'
        expect(pdf_fields['DonationsL40']).to eq '60'
        expect(pdf_fields['DonationsL41']).to eq '100'
      end
    end

    describe "refund/taxes owed" do
      before do
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_50).and_return 25
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_51).and_return 50
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_54).and_return 100
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_55).and_return 150
        allow_any_instance_of(Efile::Id::Id40Calculator).to receive(:calculate_line_56).and_return 200
      end

      it "sets the correct values for the fields" do
        expect(pdf_fields['PymntOtherCreditL50Total']).to eq '25'
        expect(pdf_fields['TxDueRefundL51']).to eq '50'
        expect(pdf_fields['TxDueRefundL54']).to eq '100'
        expect(pdf_fields['TxDueRefundL55']).to eq '150'
        expect(pdf_fields['RefundedL56']).to eq '200'
      end
    end
  end
end
