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
              xml.InitialCreation do
                device_info = StateFileEfileDeviceInfo.where(intake: @submission.data_source, event_type: "initial_creation").where.not(device_id: nil).first
                xml.IPAddress do
                  xml.IPv4AddressTxt device_info.ip_address if device_info.ip_address.ipv4?
                  xml.IPv6AddressTxt device_info.ip_address if device_info.ip_address.ipv6?
                end
                xml.IPTs datetime_type(device_info.created_at)
                xml.DeviceId device_info.device_id || 'AB' * 20 # 40 alphanumeric character field for device ID
                xml.DeviceTypeCd 'Browser-based'
              end
              xml.Submission do
                device_info = StateFileEfileDeviceInfo.where(intake: @submission.data_source, event_type: "submission").where.not(device_id: nil).first
                xml.IPAddress do
                  xml.IPv4AddressTxt device_info.ip_address if device_info.ip_address.ipv4?
                  xml.IPv6AddressTxt device_info.ip_address if device_info.ip_address.ipv6?
                end
                xml.IPTs datetime_type(device_info.created_at)
                xml.DeviceId device_info.device_id || 'AB' * 20
                xml.DeviceTypeCd 'Browser-based'
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
