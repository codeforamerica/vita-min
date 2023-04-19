module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It201 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("IT201") do |xml|
                xml.PR_DOB_DT claimed: "2023-04-10"
                xml.FS_CD claimed: 1
                xml.DEP_CLAIM_IND claimed: 2
                xml.STD_ITZ_IND claimed: 1
                xml.TXBL_INC_AMT claimed: 5000
                xml.SALE_USE_AMT claimed: 0
                xml.PR_SGN_IND claimed: 1
              end
            end
          end
        end
      end
    end
  end
end