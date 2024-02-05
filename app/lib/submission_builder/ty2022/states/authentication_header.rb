module SubmissionBuilder
  module Ty2022
    module States
      class AuthenticationHeader < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods
        include SubmissionBuilder::BusinessLogicMethods

        def document
          build_xml_doc("AuthenticationHeader") do |xml|
            xml.FilingLicenseTypeCd "O"
            xml.FinancialResolution do
              xml.Submission do
                xml.RefundProductCIPCdSubmit "0"
                ### TODO RefundDisbursementUBASubmit || NoUBADisbursementCdSubmit
                refund_disbursement(xml)
                xml.NoUBADisbursementCdSubmit "3"
                xml.NoFinancialProduct "X"
              end
            end
            xml.PrimDrvrLcnsOrStateIssdIdGrp do
              state_id_to_xml(@submission.data_source.primary_state_id, xml)
            end
            if @submission.data_source.filing_status_mfj?
              xml.SpsDrvrLcnsOrStateIssdIdGrp do
                state_id_to_xml(@submission.data_source.spouse_state_id, xml)
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

        def xml_type_for_state_id(state_id)
          if state_id&.id_type_driver_license?
            "DrvrLcns"
          elsif state_id&.id_type_dmv_bmv?
            "StateIssdId"
          end
        end

        def state_id_to_xml(state_id, xml_builder)
          xml_type = xml_type_for_state_id(state_id)
          if xml_type
            xml_builder.send("#{xml_type}Num", state_id.id_number) if state_id.id_number.present?
            xml_builder.send("#{xml_type}StCd", state_id.state) if state_id.state.present?
            xml_builder.send("#{xml_type}ExprDt") do
              if state_id.non_expiring?
                xml_builder.NonExpr "Non-Expiring"
              else
                xml_builder.ExprDt state_id.expiration_date.strftime("%Y-%m-%d") if state_id.expiration_date.present?
              end
            end
            xml_builder.send("#{xml_type}IssueDt", state_id.issue_date.strftime("%Y-%m-%d")) if state_id.issue_date.present?
            xml_builder.send("#{xml_type}AddInfo", state_id.first_three_doc_num) if state_id.first_three_doc_num.present?
          else
            xml_builder.DoNotHaveDrvrLcnsOrStIssdId "X"
          end
        end

        def refund_disbursement(xml_builder)
          binding.pry
          refund_or_owed_amount = @submission.data_source.calculated_refund_or_owed_amount
          if refund_or_owed_amount.negative? || refund_or_owed_amount.zero?
            xml_builder.NoUBADisbursementCdSubmit 0
          end
          # @submission.data_source.calculated_refund_or_owed_amount
          # @submission.data_source.calculated_refund_or_owed_amount.positive?
          # @submission.data_source.payment_or_deposit_type
          ###  enum payment_or_deposit_type: { unfilled: 0, direct_deposit: 1, mail: 2 }, _prefix: :payment_or_deposit_type
        end
      end
    end
  end
end
