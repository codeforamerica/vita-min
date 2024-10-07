# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502") do |xml|
                xml.ResidencyStatusPrimary true
                xml.TaxPeriodBeginDt date_type(Date.new(@submission.data_source.tax_return_year, 1, 1))
                xml.TaxPeriodEndDt date_type(Date.new(@submission.data_source.tax_return_year, 12, 31))
                if @submission.data_source.direct_file_data.claimed_as_dependent?
                  xml.FilingStatus 'DependentTaxpayer'
                else
                  xml.FilingStatus filing_status
                end
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_fields ||= intake.tax_calculator.calculate
            end

            # from MDIndividualeFileTypes.xsd
            FILING_STATUS_OPTIONS = {
              head_of_household: 'HeadOfHousehold',
              married_filing_jointly: 'Joint',
              married_filing_separately: 'MarriedFilingSeparately',
              qualifying_widow: 'QualifyingWidow',
              single: "Single",
            }.freeze

            def filing_status
              FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
            end
          end
        end
      end
    end
  end
end