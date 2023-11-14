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
                # ip address, IPT, device-id, device-type-cd, ip-port-num
                xml.IPAddress do
                  xml.IPv4AddressTxt '1.2.3.4'
                end
                xml.IPTs '2023-10-10T12:00:00-05:00'
                xml.DeviceId 'AB' * 20
                xml.DeviceTypeCd 'Desktop'
                xml.IPPortNum '1234'
              end
              xml.Submission do
                xml.IPAddress do
                  xml.IPv4AddressTxt '1.2.3.4'
                end
                xml.IPTs '2023-10-10T12:00:00-05:00'
                xml.DeviceId 'AB' * 20
                xml.DeviceTypeCd 'Desktop'
                xml.FinalIPPortNumberSubmit '1234'
              end
              xml.TotActiveTimePrepSubmissionTs '30'
              xml.TotalPreparationSubmissionTs '5'
            end
          end
        end
      end
    end
  end
end
