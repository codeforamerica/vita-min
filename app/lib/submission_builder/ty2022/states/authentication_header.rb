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
            xml.TransmissionDetail do
              xml.InitialCreation do
                device_info = @submission.data_source.initial_efile_device_info
                # ip_for_irs for test env
                xml.IPAddress do
                  xml.IPv4AddressTxt device_info&.ip_address if device_info&.ip_address&.ipv4?
                  xml.IPv6AddressTxt device_info&.ip_address if device_info&.ip_address&.ipv6?
                end
                xml.IPTs datetime_type(device_info&.updated_at)
                xml.DeviceId device_info&.device_id || 'AB' * 20
                xml.DeviceTypeCd 'Browser-based'
              end
              xml.Submission do
                device_info = @submission.data_source.submission_efile_device_info
                xml.IPAddress do
                  xml.IPv4AddressTxt device_info&.ip_address if device_info&.ip_address&.ipv4?
                  xml.IPv6AddressTxt device_info&.ip_address if device_info&.ip_address&.ipv6?
                end
                xml.IPTs datetime_type(device_info&.updated_at)
                xml.DeviceId device_info&.device_id || 'AB' * 20
                xml.DeviceTypeCd 'Browser-based'
              end
              xml.TotActiveTimePrepSubmissionTs state_file_total_preparation_submission_minutes
              xml.TotalPreparationSubmissionTs state_file_total_preparation_submission_minutes
            end
          end
        end
      end
    end
  end
end
