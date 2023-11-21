module SubmissionBuilder
  module Ty2022
    module States
      class AuthenticationHeader < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods
        include SubmissionBuilder::BusinessLogicMethods

        def document
          # TODO: all these are dummy values, fix up when we get access to state test environments
          build_xml_doc("efile:AuthenticationHeader") do |xml|
            xml.FilingLicenseTypeCd 'P' # or I or the other one
            xml.FinancialResolution do
              xml.Submission do
                xml.RefundProductCIPCdSubmit "0"
                xml.NoUBADisbursementCdSubmit "3"
                xml.NoFinancialProduct "X"
              end
            end
            if @submission.data_source.state_name == "New York"
              xml.PrimDrvrLcnsOrStateIssdIdGrp do
                state_id = @submission.data_source.primary_state_id
                if state_id.present? && (state_id.id_type_driver_license? || state_id.id_type_dmv_bmv?)
                  xml.DrvrLcnsNum state_id.id_number
                  xml.DrvrLcnsStCd state_id.state
                  xml.DrvrLcnsExprDt do
                    xml.ExprDt state_id.expiration_date.strftime("%Y-%m-%d")
                  end
                  xml.DrvrLcnsIssueDt state_id.issue_date.strftime("%Y-%m-%d")
                else
                  xml.DoNotHaveDrvrLcnsOrStIssdId "X"
                end
              end
              if @submission.data_source.filing_status_mfj?
                xml.SpsDrvrLcnsOrStateIssdIdGrp do
                  state_id = @submission.data_source.spouse_state_id
                  if state_id.present? && (state_id.id_type_driver_license? || state_id.id_type_dmv_bmv?)
                    xml.DrvrLcnsNum state_id.id_number
                    xml.DrvrLcnsStCd state_id.state
                    xml.DrvrLcnsExprDt do
                      xml.ExprDt state_id.expiration_date.strftime("%Y-%m-%d")
                    end
                    xml.DrvrLcnsIssueDt state_id.issue_date.strftime("%Y-%m-%d")
                  else
                    xml.DoNotHaveDrvrLcnsOrStIssdId "X"
                  end
                end
              end
            else
              # Arizona does not require us to collect state id info
              xml.PrimDrvrLcnsOrStateIssdIdGrp do
                xml.DidNotProvideDLOrStIssuedId "X"
              end
            end
            xml.TransmissionDetail do
              initial_device_info = StateFileEfileDeviceInfo.where(intake: @submission.data_source, event_type: "initial_creation").first
              submission_device_info = StateFileEfileDeviceInfo.where(intake: @submission.data_source, event_type: "submission").first

              # IP and device info
              if initial_device_info.present?
                xml.InitialCreation do
                  # ip address, IPT, device-id, device-type-cd, ip-port-num
                  xml.IPAddress do
                    xml.IPv4AddressTxt initial_device_info.ip_address if initial_device_info.ip_address.ipv4?
                    xml.IPv6AddressTxt initial_device_info.ip_address if initial_device_info.ip_address.ipv6?
                  end
                  xml.IPTs datetime_type(initial_device_info.created_at)
                  xml.DeviceId initial_device_info.device_id || 'AB' * 20 # 40 alphanumeric character field for device ID
                  xml.DeviceTypeCd 'Browser-based'
                end
              end
              if submission_device_info.present?
                xml.Submission do
                  xml.IPAddress do
                    xml.IPv4AddressTxt submission_device_info.ip_address if submission_device_info.ip_address.ipv4?
                    xml.IPv6AddressTxt submission_device_info.ip_address if submission_device_info.ip_address.ipv6?
                  end
                  xml.IPTs datetime_type(submission_device_info.created_at)
                  xml.DeviceId submission_device_info.device_id || 'AB' * 20
                  xml.DeviceTypeCd 'Browser-based'
                end
              end
              xml.TotActiveTimePrepSubmissionTs '30' # total_active_preparation_minutes -- Total Active Time Preparation Submission Time Span
              xml.TotalPreparationSubmissionTs '5' # total_preparation_submission_minutes
            end
          end
        end
      end
    end
  end
end
