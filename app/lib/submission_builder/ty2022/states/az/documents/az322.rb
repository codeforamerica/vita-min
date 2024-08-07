module SubmissionBuilder
  module Ty2022
    module States
      module Az
        module Documents
          class Az322 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form322") do |xml|
                @submission.data_source.az322_contributions.each_with_index do |contribution, index|
                  break if index >= 3
                  xml.SContribMadeTo do
                    xml.SchoolContrDate contribution.date_of_contribution
                    xml.CTDSCode contribution.ctds_code
                    xml.SchoolName contribution.school_name
                    xml.SchoolDist contribution.district_name
                    xml.Contributions contribution.amount
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
