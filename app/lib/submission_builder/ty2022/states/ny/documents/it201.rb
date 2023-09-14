module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class It201 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              # TODO: all these are dummy values, fix up when we get access to state test environments
              build_xml_doc("IT201") do |xml|
                xml.PR_DOB_DT claimed: @submission.data_source.primary.birth_date.strftime("%Y-%m-%d")
                xml.FS_CD claimed: 1
                xml.DEP_CLAIM_IND claimed: 2
                xml.FEDAGI_B4_ADJ_AMT claimed: calculated_fields['AMT_17']
                xml.STD_ITZ_IND claimed: 1
                xml.DED_AMT claimed: calculated_fields['AMT_34']
                xml.TXBL_INC_AMT claimed: 5000
                xml.SALE_USE_AMT claimed: 0
                xml.PR_SGN_IND claimed: 1
              end
            end

            private

            def calculated_fields
              @it201_fields ||=
                begin
                  it201 = Efile::Ny::It201.new(
                    year: 2022,
                    filing_status: @submission.data_source.filing_status.to_sym,
                    claimed_as_dependent: false,
                    dependent_count: 0,
                    lines: {
                      AMT_2: @submission.data_source.fed_taxable_income,
                    },
                    it227: Efile::Ny::It227.new
                  )
                  it201.calculate
                end
            end
          end
        end
      end
    end
  end
end