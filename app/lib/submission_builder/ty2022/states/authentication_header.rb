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
              xml.DoNotHaveDrvrLcnsOrStIssdId "X"
            end
            xml.TransmissionDetail do
              xml.InitialCreation do
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
