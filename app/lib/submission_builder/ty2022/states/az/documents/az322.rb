module SubmissionBuilder
  module Ty2022
    module States
      module Az
        module Documents
          class Az322 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form322") do |xml|
                @submission.data_source.az322_contributions.first(3).each do |contribution|
                  xml.SContribMadeTo do
                    xml.SchoolContrDate contribution.date_of_contribution
                    xml.CTDSCode contribution.ctds_code
                    xml.SchoolName contribution.school_name
                    xml.SchoolDist contribution.district_name
                    xml.Contributions contribution.amount.round
                  end
                end
                if calculated_fields.fetch(:AZ322_LINE_4) > 0
                  xml.TotalContributionsContSheet calculated_fields.fetch(:AZ322_LINE_4)
                end
                xml.TotalContributions calculated_fields.fetch(:AZ322_LINE_5)
                xml.SubTotalAmt calculated_fields.fetch(:AZ322_LINE_11)
                xml.SingleHOH calculated_fields.fetch(:AZ322_LINE_12)
                xml.CurrentYrCr calculated_fields.fetch(:AZ322_LINE_13)
                xml.TotalAvailCr calculated_fields.fetch(:AZ322_LINE_22)
                if @submission.data_source.az322_contributions.count > 3
                  xml.ContinuationPages do
                    @submission.data_source.az322_contributions.drop(3).each do |contribution|
                      xml.SContribMadeTo do
                        xml.SchoolContrDate contribution.date_of_contribution
                        xml.CTDSCode contribution.ctds_code
                        xml.SchoolName contribution.school_name
                        xml.SchoolDist contribution.district_name
                        xml.Contributions contribution.amount.round
                      end
                    end
                    xml.TotalContributions calculated_fields.fetch(:AZ322_LINE_4)
                    xml.TotalContributionsAfter 0
                  end
                end
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
