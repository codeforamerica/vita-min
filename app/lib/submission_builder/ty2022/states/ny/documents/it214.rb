module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It214 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT214") do |xml|
                xml.PR_DOB_DT claimed: @submission.data_source.primary.birth_date.strftime("%Y-%m-%d")
                xml.R_RSDT_IND claimed: 1
                xml.R_OCCPY_RSDT_IND claimed: 1
                xml.R_RL_PROP_VL_IND claimed: 2
                xml.R_DEPDT_IND claimed: 2
                xml.R_RSDT_EXMPT_IND claimed: 2
                xml.R_NRS_HOME_IND claimed: 2
                xml.R_FEDAGI_AMT claimed: calculated_fields.fetch('IT214_LINE_9')
                xml.R_RL_PROP_TX_AMT claimed: 1 # TODO, dummy value right now because it's required

                # TODO: signature stuff is mostly here to make the xml valid, revisit later
                xml.PR_SGN_IND claimed: 1
                xml.ERO_SGN_IND claimed: 1
              end
            end

            private

            def calculated_fields
              @calculated_fields ||= @submission.data_source.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end
