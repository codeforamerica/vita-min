# References:
# Attachment to MeF IMF Schemas for Tax Year 2020
# https://drive.google.com/file/d/1WlDJ8jtVxTlTPbxNuaFfUhAaG8nDcJE-/view?usp=sharing
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
      security_information = client.efile_security_information
      address = submission.address

      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml['efile'].ReturnHeader(root_node_attrs) {
          xml.ReturnTs datetime_type(submission.created_at)
          xml.TaxYr tax_return.year
          xml.TaxPeriodBeginDt date_type(Date.new(tax_return.year, 1, 1))
          xml.TaxPeriodEndDt date_type(Date.new(tax_return.year, 12, 31))
          if submission.imperfect_return_resubmission?
            xml.ImperfectReturnIndicator "X"
          end
          xml.SoftwareId EnvironmentCredentials.dig(:irs, :sin)
          xml.OriginatorGrp {
            xml.EFIN EnvironmentCredentials.dig(:irs, :efin)
            xml.OriginatorTypeCd "OnlineFiler"
          }
          xml.SelfSelectPINGrp {
            xml.PrimaryBirthDt date_type(intake.primary_birth_date)
            if tax_return.filing_jointly?
              xml.SpouseBirthDt date_type(intake.spouse_birth_date) if tax_return.filing_jointly?
            end
            xml.PrimaryPriorYearAGIAmt 0
            xml.SpousePriorYearAGIAmt 0 if tax_return.filing_jointly?
          }
          xml.IdentityProtectionPIN intake.primary_ip_pin if intake.primary_ip_pin.present?
          xml.SpouseIdentityProtectionPIN intake.spouse_ip_pin if tax_return.filing_jointly? && intake.spouse_ip_pin.present?
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
            xml.NameLine1Txt name_line_1_type(intake.primary_first_name, intake.primary_middle_initial, intake.primary_last_name, intake.spouse_first_name, intake.spouse_middle_initial, intake.spouse_last_name)
            xml.PrimaryNameControlTxt person_name_control_type(client.legal_name)
            xml.SpouseNameControlTxt person_name_control_type(client.spouse_legal_name) if tax_return.filing_jointly?
            xml.USAddress {
              xml.AddressLine1Txt address.street_address
              xml.CityNm address.city
              xml.StateAbbreviationCd address.state
              xml.ZIPCd address.zip_code
            }
            if intake.sms_phone_number || intake.phone_number
              xml.PhoneNum phone_type(intake.sms_phone_number || intake.phone_number)
            end
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
                xml.BankAccountDataCapturedTs datetime_type(intake.bank_account.created_at)
              end
              xml.CellPhoneNum phone_type(intake.sms_phone_number) if intake.sms_phone_number.present?
              xml.EmailAddressTxt intake.email_address if intake.email_address.present?
            }
            xml.AtSubmissionFilingGrp {
              xml.RefundProductElectionInd false

              xml.RefundDisbursementGrp {
                xml.RefundDisbursementCd refund_disbursement_code
                if intake.refund_payment_method_direct_deposit?
                  xml.RoutingTransitNum intake.bank_account.routing_number
                  xml.DepositorAccountNum intake.bank_account.account_number
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
                xml.IPv4AddressTxt security_information.ip_address if security_information.ip_address.ipv4?
                xml.IPv6AddressTxt security_information.ip_address if security_information.ip_address.ipv6?
              }
              # TODO: Include if we can get value from Aptible. Otherwise, do not include.
              # xml.IPPortNum
              xml.DeviceId security_information.device_id || "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
              xml.DeviceTypeCd 1
              xml.UserAgentTxt security_information.user_agent
              xml.BrowserLanguageTxt security_information.browser_language
              xml.PlatformTxt security_information.platform
              xml.TimeZoneOffsetNum security_information.timezone_offset
              xml.SystemTs datetime_type(security_information.client_system_datetime)
            }
            xml.AtSubmissionFilingGrp {
              xml.IPAddress {
                xml.IPv4AddressTxt intake.primary_consented_to_service_ip
              }
              # TODO: Include if we can get value from Aptible. Otherwise, do not include.
              # xml.FinalIPPortNum
              # TODO: Swap out device ID with 40 digit code provided by IRS device ID JS
              xml.DeviceId 9162213099514827927117083645386143446039
              xml.DeviceTypeCd 1
              # TODO: Replace with information gathered from browser at client/intake creation
              # xml.UserAgentTxt
              # xml.BrowserLanguageTxt
              # xml.PlatformTxt
              # xml.TimeZoneOffsetNum
              # xml.SystemTs
            }
            if submission.resubmission?
              xml.FederalOriginalSubmissionId submission.previously_transmitted_submission.irs_submission_id
              xml.FederalOriginalSubmissionDt date_type(submission.previously_transmitted_submission.created_at)
            end
            xml.TotalPreparationSubmissionTs total_preparation_submission_minutes
            xml.TotActiveTimePrepSubmissionTs total_active_preparation_minutes
            xml.VendorControlNum "2P00000000000001"
          }
        }
      end.doc
    end

    # 0 - zero balance
    # 2 - bank account
    # 3 - check
    def refund_disbursement_code
      return 0 if submission.tax_return.claimed_recovery_rebate_credit.zero?

      submission.intake.refund_payment_method_direct_deposit? ? 2 : 3
    end

    def oob_security_verification_code
      return "03" if submission.intake.email_address_verified_at.present?
      return "07" if submission.intake.sms_phone_number_verified_at.present?
    end

    # 0 - initiating IP == submission IP
    # 1 - initiating IP != submission IP
    def last_submission_rqr_oob_code
      submission.client.first_sign_in_ip == submission.client.last_sign_in_ip ? 0 : 1
    end

    # Subtracting two DateTime from ActiveSupport::TimeWithZone provide distance of time in seconds
    # Divide by 60 to get distance of time in minutes
    def total_preparation_submission_minutes
      ((DateTime.now - submission.client.created_at.to_datetime) / 60).to_i
    end

    # TODO: replaced with a "counter" of active time spent prepping
    # captures the amount of active time within the application until submission
    def total_active_preparation_minutes
      15
    end
  end
end
