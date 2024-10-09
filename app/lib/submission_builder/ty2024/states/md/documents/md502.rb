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
                income_section(xml)
              end
            end

            private

            def income_section(root_xml)
              root_xml.Income do |income|
                income.FederalAdjustedGrossIncome calculated_fields.fetch(:MD502_LINE_1)
                income.WagesSalariesAndTips calculated_fields.fetch(:MD502_LINE_1A)
                income.EarnedIncome calculated_fields.fetch(:MD502_LINE_1B)
                income.TaxablePensionsIRAsAnnuities calculated_fields.fetch(:MD502_LINE_1D)
                income.InvestmentIncomeIndicator calculated_fields.fetch(:MD502_LINE_1E) ? "X" : ""
              end
            end

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