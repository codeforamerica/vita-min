module SubmissionBuilder
  class ReturnHeader1040 < SubmissionBuilder::Base
    include SubmissionBuilder::FormattingMethods

    @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "ReturnHeader1040x.xsd")
    @root_node = "ReturnHeader"

    def root_node_attrs
      super.merge("binaryAttachmentCnt": 0)
    end

    def document
      tax_return = submission.tax_return
      intake = submission.intake
      client = submission.client

      Nokogiri::XML::Builder.new do |xml|
        xml['efil'].ReturnHeader(root_node_attrs) {
          xml.ReturnTs datetime_type(submission.created_at)
          xml.TaxYr tax_return.year
          xml.TaxPeriodBeginDt date_type(Date.new(tax_return.year, 1, 1))
          xml.TaxPeriodEndDt date_type(Date.new(tax_return.year, 12, 31))
          if submission.imperfect_return_resubmission?
            xml.ImperfectReturnIndicator "X"
          end
          # TODO: REPLACE AS ENVIRONMENT VARIABLE WHEN WE GET SOFTWARE ID
          xml.SoftwareId "11111111"
          xml.OriginatorGrp {
            xml.EFIN EnvironmentCredentials.dig(:irs, :efin)
            xml.OriginatorTypeCd "OnlineFiler"
          }
          xml.PINTypeCd "Self-Select On-Line"
          xml.JuratDisclosureCd "Online Self Select PIN"
          xml.PrimaryPINEnteredByCd "Taxpayer"
          xml.PrimarySignaturePIN intake.primary_signature_pin
          xml.SpouseSignaturePIN intake.spouse_signature_pin if tax_return.filing_jointly?
          xml.PrimarySignatureDt date_type(intake.primary_signature_pin_at)
          xml.SpouseSignatureDt date_type(intake.spouse_signature_pin_at) if tax_return.filing_jointly?
          xml.ReturnTypeCd "1040"
          xml.Filer {
            xml.PrimarySSN intake.primary_ssn
            xml.SpouseSSN intake.spouse_ssn if tax_return.filing_jointly?
            xml.NameLine1Txt trim(client.legal_name, 35)
            xml.PrimaryNameControlTxt person_name_control_type(client.legal_name)
            xml.SpouseNameControlTxt person_name_control_type(client.spouse_legal_name) if tax_return.filing_jointly?
            # TODO: Replace with IRS formatted address for client when ready
            xml.USAddress {
              xml.AddressLine1Txt "23627 HAWKINS CREEK CT"
              xml.CityNm "KATY"
              xml.StateAbbreviationCd "TX"
              xml.ZIPCd "77494"
            }
            xml.PhoneNum phone_type(intake.phone_number)
          }
          xml.OnlineFilerInformation {
            if intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum intake.bank_account.routing_number
              xml.DepositorAccountNum intake.bank_account.account_number
            else
              xml.CheckCd "Check"
            end
          }
          xml.AdditionalFilerInformation {
            xml.AtSubmissionCreationGrp {
              if intake.refund_payment_method_direct_deposit?
                xml.RoutingTransitNum intake.bank_account.routing_number
                xml.DepositorAccountNum intake.bank_account.account_number
                xml.BankAccountDataCapturedTs intake.completed_at # TODO: Replace with more accurate timestamp.
              end
              xml.CellPhoneNum phone_type(intake.sms_phone_number) if intake.sms_phone_number.present?
              xml.EmailAddressTxt intake.email_address if intake.email_address.present?
            }
          }
          xml.FilingSecurityInformation {
            xml.AtSubmissionFilingGrp {
              xml.IPAddress {
                xml.IPv4AddressTxt intake.primary_consented_to_service_ip
              }
            }
          }
        }
      end.doc
    end
  end
end