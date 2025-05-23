require 'rails_helper'

describe SubmissionBuilder::FinancialTransaction do
  describe '.build' do
    let(:intake) { create(:state_file_az_owed_intake) }
    let(:kwargs) { {} }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:xml) {
      Nokogiri::XML::Document.parse(
        described_class.build(
          submission, validate: false, kwargs: kwargs
        ).document.to_xml)
    }
    context "when filer owes money" do
      it "populates the StatePayment" do
        expect(xml.at("StatePayment Checking").text).to eq "X"
        expect(xml.at("StatePayment RoutingTransitNumber").text).to eq "111111111"
        expect(xml.at("StatePayment BankAccountNumber").text).to eq "222222222"
        expect(xml.at("StatePayment PaymentAmount").text).to eq "5"
        expect(xml.at("StatePayment NotIATTransaction").text).to eq "X"
        # Removing after April 15th
        # expect(xml.at("StatePayment RequestedPaymentDate").text).to eq "2024-04-15"
        expect(xml.at("StatePayment AccountHolderType")).to be_nil
        expect(xml.at("AddendaRecord TaxTypeCode FTACode")).to be_nil
        expect(xml.at("AddendaRecord TaxTypeCode StateTaxTypeCode")).to be_nil
        expect(xml.at("AddendaRecord TaxPeriodEndDate")).to be_nil
        expect(xml.at("AddendaRecord TXPAmount SubAmountType")).to be_nil
        expect(xml.at("AddendaRecord TXPAmount SubAmount")).to be_nil
      end

      context "with date_electronic_withdrawal" do
        let(:intake) { create(:state_file_az_owed_intake, date_electronic_withdrawal: Date.new(2024, 4, 15)) }
        let(:submission_created_at) { Time.zone.local(2025, 4, 10, 12, 0, 0) }
        let!(:submission) { create(:efile_submission, data_source: intake, created_at: submission_created_at) }

        it "sets RequestedPaymentDate to the user selected date when submitted before payment deadline" do
          expect(xml.at("StatePayment RequestedPaymentDate").text).to eq "2024-04-15"
        end

        context "when submitted after payment deadline" do
          let(:submission_created_at) { Time.zone.local(2025, 4, 17, 12, 0, 0) }

          it "sets RequestedPaymentDate to the submission date" do
            expect(xml.at("StatePayment RequestedPaymentDate").text).to eq "2025-04-17"
          end
        end

        context "when submitted exactly on payment deadline" do
          let(:submission_created_at) { Time.zone.local(2025, 4, 15, 12, 0, 0) }

          it "sets RequestedPaymentDate to the submission date" do
            expect(xml.at("StatePayment RequestedPaymentDate").text).to eq "2025-04-15"
          end
        end
      end

      context "in a state that requests additional debit information" do
        let(:intake) { create(:state_file_nc_intake, :taxes_owed) }

        it "populates the StatePayment with additional information" do
          expect(xml.at("StatePayment Checking").text).to eq "X"
          expect(xml.at("StatePayment RoutingTransitNumber").text).to eq "111111111"
          expect(xml.at("StatePayment BankAccountNumber").text).to eq "222222222"
          expect(xml.at("StatePayment PaymentAmount").text).to eq "5"
          expect(xml.at("StatePayment NotIATTransaction").text).to eq "X"
          # Removing after April 15th
          # expect(xml.at("StatePayment RequestedPaymentDate").text).to eq "2024-04-15"
          expect(xml.at("StatePayment AccountHolderType").text).to eq "2"
          expect(xml.at("AddendaRecord TaxTypeCode FTACode").text).to eq "010"
          expect(xml.at("AddendaRecord TaxTypeCode StateTaxTypeCode").text).to eq "00"
          expect(xml.at("AddendaRecord TaxPeriodEndDate").text).to eq(Date.new(intake.tax_return_year, 12, 31).strftime("%F"))
          expect(xml.at("AddendaRecord TXPAmount SubAmountType").text).to eq "0"
          expect(xml.at("AddendaRecord TXPAmount SubAmount").text).to eq "5"
        end
      end
    end

    context "when filer gets a refund" do
      let(:intake) { create(:state_file_az_refund_intake) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:kwargs) { { refund_amount: 5 } }

      it "populates the RefundDirectDeposit" do
        expect(xml.at("RefundDirectDeposit Savings").text).to eq "X"
        expect(xml.at("RefundDirectDeposit RoutingTransitNumber").text).to eq "111111111"
        expect(xml.at("RefundDirectDeposit BankAccountNumber").text).to eq "222222222"
        expect(xml.at("RefundDirectDeposit Amount").text).to eq "5"
        expect(xml.at("RefundDirectDeposit NotIATTransaction").text).to eq "X"
      end
    end
  end
end
