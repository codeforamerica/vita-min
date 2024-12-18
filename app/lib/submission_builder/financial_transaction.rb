module SubmissionBuilder
  class FinancialTransaction < SubmissionBuilder::Document
    def document
      build_xml_doc("FinancialTransaction") do |xml|
        if (@kwargs[:refund_amount] || 0).positive? # REFUND
          xml.RefundDirectDeposit do
            xml.RoutingTransitNumber sanitize_for_xml(@submission.data_source.routing_number) if @submission.data_source.routing_number.present?
            xml.BankAccountNumber sanitize_for_xml(@submission.data_source.account_number) if @submission.data_source.account_number.present?
            xml.Amount @kwargs[:refund_amount] if @submission.data_source.allows_refund_amount_in_xml?
            case @submission.data_source.account_type
            when 'checking'
              xml.Checking 'X'
            when 'savings'
              xml.Savings 'X'
            end
            xml.NotIATTransaction 'X'
          end
        elsif (@submission.data_source.withdraw_amount || 0).positive? # OWE
          xml.StatePayment do
            case @submission.data_source.account_type
            when 'checking'
              xml.Checking 'X'
            when 'savings'
              xml.Savings 'X'
            end
            xml.RoutingTransitNumber sanitize_for_xml(@submission.data_source.routing_number) if @submission.data_source.routing_number.present?
            xml.BankAccountNumber sanitize_for_xml(@submission.data_source.account_number) if @submission.data_source.account_number.present?
            xml.PaymentAmount @submission.data_source.withdraw_amount if @submission.data_source.withdraw_amount.present?
            xml.AccountHolderType "2" if @submission.data_source.requires_additional_debit_information?
            xml.RequestedPaymentDate date_type(@submission.data_source.date_electronic_withdrawal) if @submission.data_source.date_electronic_withdrawal.present?
            xml.NotIATTransaction 'X'
            if @submission.data_source.requires_additional_debit_information?
              xml.AddendaRecord do
                xml.TaxTypeCode "01000"
                xml.TaxPeriodEndDate date_type(Date.new(@submission.data_source.tax_return_year, 12, 31))
                xml.TXPAmount do
                  xml.SubAmountType "0"
                  xml.Subamount @submission.data_source.withdraw_amount if @submission.data_source.withdraw_amount.present?
                end
              end
            end
          end
        end
      end
    end

    def schema_file
      SchemaFileLoader.load_file("us_states", "unpacked", "AZIndividual2024v2.0", "Common", "FinancialTransaction.xsd")
    end
  end
end
