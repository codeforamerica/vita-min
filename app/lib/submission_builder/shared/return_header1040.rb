# There do not seem to be significant, applicable differences between the return header schema for 2021 to 2020,
# so it seems like we can use the same logic.
#
module SubmissionBuilder
  module Shared
    class ReturnHeader1040 < SubmissionBuilder::Document
      include SubmissionBuilder::FormattingMethods
      include SubmissionBuilder::BusinessLogicMethods

      def schema_file
        SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "ReturnHeader1040x.xsd")
      end

      def document
        tax_return = submission.tax_return
        intake = submission.intake
        client = submission.client
        primary_drivers_license = intake.primary_drivers_license
        spouse_drivers_license = intake.spouse_drivers_license
        creation_security_information = client.efile_security_informations.first
        filing_security_information = client.efile_security_informations.last
        address = submission.verified_address

        build_xml_doc("efile:ReturnHeader", "binaryAttachmentCnt": 0) do |xml|
          xml.ReturnTs datetime_type(submission.created_at)
          xml.TaxYr tax_return.year
          xml.TaxPeriodBeginDt date_type(Date.new(tax_return.year, 1, 1))
          xml.TaxPeriodEndDt date_type(Date.new(tax_return.year, 12, 31))
          if submission.imperfect_return_resubmission?
            xml.ImperfectReturnInd "X"
          end
          xml.SoftwareId EnvironmentCredentials.irs(:sin)
          xml.OriginatorGrp {
            xml.EFIN EnvironmentCredentials.irs(:efin)
            xml.OriginatorTypeCd "OnlineFiler"
          }
          xml.SelfSelectPINGrp {
            xml.PrimaryBirthDt date_type(intake.primary.birth_date)
            xml.SpouseBirthDt date_type(intake.spouse.birth_date) if tax_return.filing_jointly?
            if intake.primary_prior_year_signature_pin.present?
              xml.PrimaryPriorYearPIN intake.primary_prior_year_signature_pin
            else
              xml.PrimaryPriorYearAGIAmt primary_prior_year_agi(intake, tax_return.year)
            end
            if tax_return.filing_jointly?
              if intake.spouse_prior_year_signature_pin.present?
                xml.SpousePriorYearPIN intake.spouse_prior_year_signature_pin
              else
                xml.SpousePriorYearAGIAmt spouse_prior_year_agi(intake, tax_return.year)
              end
            end
          }
          xml.IdentityProtectionPIN intake.primary_ip_pin if intake.primary_ip_pin.present?
          xml.SpouseIdentityProtectionPIN intake.spouse_ip_pin if tax_return.filing_jointly? && intake.spouse_ip_pin.present?
          xml.PINTypeCd "Self-Select On-Line"
          xml.JuratDisclosureCd "Online Self Select PIN"
          xml.PrimaryPINEnteredByCd "Taxpayer"
          xml.SpousePINEnteredByCd "Taxpayer" if tax_return.filing_jointly?
          xml.PrimarySignaturePIN intake.primary_signature_pin
          xml.SpouseSignaturePIN intake.spouse_signature_pin if tax_return.filing_jointly?

          xml.PrimarySignatureDt date_type(intake.primary_signature_pin_at)
          xml.SpouseSignatureDt date_type(intake.spouse_signature_pin_at) if tax_return.filing_jointly?
          xml.ReturnTypeCd "1040"
          xml.Filer {
            xml.PrimarySSN intake.primary.ssn
            xml.SpouseSSN intake.spouse.ssn if tax_return.filing_jointly?
            xml.NameLine1Txt name_line_1(tax_return, intake)
            xml.PrimaryNameControlTxt name_control_type(intake.primary.last_name)
            xml.SpouseNameControlTxt spouse_name_control(intake) if tax_return.filing_jointly?
            # If the address has not been validated, skip this tag.
            if address.present?
              xml.USAddress {
                # IRS provides no information on how to shorten addresses
                # but requires that they be < 36 characters long
                xml.AddressLine1Txt trim([address.urbanization, address.street_address].map(&:presence).compact.join(" "), 35)
                xml.CityNm trim(address.city, 22)
                xml.StateAbbreviationCd address.state
                xml.ZIPCd address.zip_code
              }
            end
            if intake.sms_phone_number || intake.phone_number
              xml.PhoneNum phone_type(intake.sms_phone_number || intake.phone_number)
            end
          }
          xml.OnlineFilerInformation {
            if intake.refund_payment_method_direct_deposit?
              xml.RoutingTransitNum account_number_type(intake.bank_account.routing_number) if intake.bank_account.routing_number.present?
              xml.DepositorAccountNum account_number_type(intake.bank_account.account_number) if intake.bank_account.account_number.present?
            else
              xml.CheckCd "Check"
            end
          }
          xml.AdditionalFilerInformation {
            xml.AtSubmissionCreationGrp {
              if intake.refund_payment_method_direct_deposit?
                xml.RoutingTransitNum account_number_type(intake.bank_account.routing_number)
                xml.DepositorAccountNum account_number_type(intake.bank_account.account_number)
                xml.BankAccountDataCapturedTs datetime_type(intake.bank_account.created_at)
              end
              xml.CellPhoneNum phone_type(intake.sms_phone_number) if intake.sms_phone_number.present?
              xml.EmailAddressTxt intake.email_address if intake.email_address.present?
            }
            if primary_drivers_license.present?
              xml.PrimDrvrLcnsOrStateIssdIdGrp do
                drivers_license_xml(xml, primary_drivers_license)
              end
            end
            if tax_return.filing_jointly? && spouse_drivers_license.present?
              xml.SpsDrvrLcnsOrStateIssdIdGrp do
                drivers_license_xml(xml, spouse_drivers_license)
              end
            end
            xml.AtSubmissionFilingGrp {
              xml.RefundProductElectionInd false

              xml.RefundDisbursementGrp {
                xml.RefundDisbursementCd refund_disbursement_code
                if intake.refund_payment_method_direct_deposit?
                  xml.RoutingTransitNum account_number_type(intake.bank_account.routing_number)
                  xml.DepositorAccountNum account_number_type(intake.bank_account.account_number)
                end
                xml.RefundProductCIPCd 0
              }
            }
            xml.TrustedCustomerGrp {
              xml.TrustedCustomerCd 0 # New customer
              xml.OOBSecurityVerificationCd oob_security_verification_code if oob_security_verification_code.present?
              xml.LastSubmissionRqrOOBCd last_submission_rqr_oob_code
              xml.AuthenticationAssuranceLevelCd "AAL1"
              # These fields should be "X" (checked) if we served this client last year with different contact info. This is
              # our first e-filing year, so they're always omitted (unchecked).
              # xml.ProfileUserNameChangeInd ""
              # xml.ProfilePasswordChangeInd ""
              # xml.ProfileEmailAddressChangeInd ""
              # xml.ProfileCellPhoneNumChangeInd ""
            }
          }
          xml.FilingSecurityInformation {
            xml.AtSubmissionCreationGrp {
              xml.IPAddress {
                xml.IPv4AddressTxt creation_security_information.ip_address if creation_security_information.ip_address.ipv4?
                xml.IPv6AddressTxt creation_security_information.ip_address if creation_security_information.ip_address.ipv6?
              }
              # xml.IPPortNum omitted because we cannot get TCP client port number easily from Aptible.
              xml.DeviceId creation_security_information.device_id || "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
              xml.DeviceTypeCd 1
              xml.UserAgentTxt trim(creation_security_information.user_agent, 150)
              xml.BrowserLanguageTxt trim(creation_security_information.browser_language, 5)
              xml.PlatformTxt trim(creation_security_information.platform, 15)
              xml.TimeZoneOffsetNum time_zone_offset_type(creation_security_information.timezone_offset)
              xml.SystemTs datetime_type(creation_security_information.client_system_datetime)
            }
            xml.AtSubmissionFilingGrp {
              xml.IPAddress {
                xml.IPv4AddressTxt filing_security_information.ip_address if filing_security_information.ip_address.ipv4?
                xml.IPv6AddressTxt filing_security_information.ip_address if filing_security_information.ip_address.ipv6?
              }
              xml.DeviceId filing_security_information.device_id || "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
              xml.DeviceTypeCd 1
              xml.UserAgentTxt trim(filing_security_information.user_agent, 150)
              xml.BrowserLanguageTxt trim(filing_security_information.browser_language, 5)
              xml.PlatformTxt trim(filing_security_information.platform, 15)
              xml.TimeZoneOffsetNum time_zone_offset_type(filing_security_information.timezone_offset)
              xml.SystemTs datetime_type(filing_security_information.client_system_datetime)
            }
            if submission.resubmission?
              xml.FederalOriginalSubmissionId submission.previously_transmitted_submission.irs_submission_id
              xml.FederalOriginalSubmissionIdDt date_type(submission.previously_transmitted_submission.created_at)
            end
            xml.TotalPreparationSubmissionTs total_preparation_submission_minutes
            xml.TotActiveTimePrepSubmissionTs total_active_preparation_minutes
            xml.VendorControlNum "2P00000000000001"
          }
        end
      end

      def drivers_license_xml(xml, drivers_license)
        xml.DrvrLcnsOrStateIssdIdNum drivers_license.license_number
        xml.DrvrLcnsOrStateIssdIdStCd drivers_license.state
        xml.DrvrLcnsOrStateIssdIdExprDt date_type(drivers_license.expiration_date)
        xml.DrvrLcnsOrStateIssdIdIssDt date_type(drivers_license.issue_date)
      end
    end
  end
end
