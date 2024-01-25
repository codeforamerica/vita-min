module SubmissionBuilder
  module Ty2022
    module States
      class FinancialTransaction < SubmissionBuilder::Document

        def document
          build_xml_doc("FinancialTransaction") do |xml|
            if (@kwargs[:refund_amount] || 0).positive? # REFUND
              xml.RefundDirectDeposit do
                xml.RoutingTransitNumber @submission.data_source.routing_number
                xml.BankAccountNumber @submission.data_source.account_number
                xml.Amount @kwargs[:refund_amount]
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
                xml.RoutingTransitNumber @submission.data_source.routing_number
                xml.BankAccountNumber @submission.data_source.account_number
                xml.PaymentAmount @submission.data_source.withdraw_amount
                xml.RequestedPaymentDate date_type(@submission.data_source.date_electronic_withdrawal) unless @submission.data_source.date_electronic_withdrawal.nil?
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
