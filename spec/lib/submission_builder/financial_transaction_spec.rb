require 'rails_helper'

describe SubmissionBuilder::FinancialTransaction do
  describe '.build' do
    context "when filer owes money" do
      let(:intake) { create(:state_file_az_owed_intake) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      it "populates the StatePayment" do
        xml = Nokogiri::XML::Document.parse(
          described_class.build(
            submission, validate: false
          ).document.to_xml)
        expect(xml.at("StatePayment Checking").text).to eq "X"
        expect(xml.at("StatePayment RoutingTransitNumber").text).to eq "111111111"
        expect(xml.at("StatePayment BankAccountNumber").text).to eq "222222222"
        expect(xml.at("StatePayment PaymentAmount").text).to eq "5"
        expect(xml.at("StatePayment NotIATTransaction").text).to eq "X"
        # Removing after April 15th
        # expect(xml.at("StatePayment RequestedPaymentDate").text).to eq "2024-04-15"
      end
    end

    context "when filer gets a refund" do
      let(:intake) { create(:state_file_az_refund_intake) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      before do
        @xml = Nokogiri::XML::Document.parse(
          described_class.build(
            submission, validate: false, kwargs: { refund_amount: 5 }
          ).document.to_xml)
      end

      it "populates the RefundDirectDeposit" do
        expect(@xml.at("RefundDirectDeposit Savings").text).to eq "X"
        expect(@xml.at("RefundDirectDeposit RoutingTransitNumber").text).to eq "111111111"
        expect(@xml.at("RefundDirectDeposit BankAccountNumber").text).to eq "222222222"
        expect(@xml.at("RefundDirectDeposit Amount").text).to eq "5"
        expect(@xml.at("RefundDirectDeposit NotIATTransaction").text).to eq "X"
      end

      context "does not allow split direct deposit amount" do
        let(:intake) { create(:state_file_md_refund_intake) }

        it "does not includes RefundDirectDeposit Amount" do
          expect(@xml.at("RefundDirectDeposit Amount")).to be_nil
        end
      end
    end

  end
end
