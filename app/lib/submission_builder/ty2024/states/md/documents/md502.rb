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
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end