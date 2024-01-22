module SubmissionBuilder
  module Ty2022
    module States
      class FinancialTransaction < SubmissionBuilder::Document

        def document
          return if @kwargs[:return_balance].nil?
          build_xml_doc("FinancialTransaction") do |xml|
            if @kwargs[:return_balance].positive? # REFUND
              xml.RefundDirectDeposit do
                xml.RoutingTransitNumber @submission.data_source.routing_number
                xml.BankAccountNumber @submission.data_source.account_number
                xml.Amount @kwargs[:return_balance]
                case @submission.data_source.account_type
                when 'checking'
                  xml.Checking 'X'
                when 'savings'
                  xml.Savings 'X'
                end
                xml.NotIATTransaction 'X'
              end
            else # OWE
              xml.StatePayment do
                xml.RoutingTransitNumber @submission.data_source.routing_number
                xml.BankAccountNumber @submission.data_source.account_number
                xml.PaymentAmount 0 - @kwargs[:return_balance]
                xml.RequestedPaymentDate date_type(@submission.data_source.date_electronic_withdrawal) unless @submission.data_source.date_electronic_withdrawal.nil?
                case @submission.data_source.account_type
                when 'checking'
                  xml.Checking 'X'
                when 'savings'
                  xml.Savings 'X'
                end
                xml.NotIATTransaction 'X'
              end
            end
          end
        end

        def schema_file
          File.join(Rails.root, "vendor", "us_states", "unpacked", "AZIndividual2023v1.0", "Common", "FinancialTransaction.xsd")
        end
      end
    end
  end
end
