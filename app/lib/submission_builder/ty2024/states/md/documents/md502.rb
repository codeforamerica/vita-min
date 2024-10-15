# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502", documentId: "Form502") do |xml|
                if @submission.data_source.direct_file_data.claimed_as_dependent?
                  xml.FilingStatus do
                    xml.DependentTaxpayer "X"
                  end
                elsif @submission.data_source.filing_status == :married_filing_separately
                  xml.FilingStatus do
                    xml.MarriedFilingSeparately "X", spouseSSN: @submission.data_source.direct_file_data.spouse_ssn
                  end
                else
                  xml.FilingStatus do
                    xml.send(filing_status, "X")
                  end
                end
                if has_exemptions
                  xml.Exemptions do
                    if has_dependent_exemption
                      xml.Dependents do
                        xml.Count calculated_fields.fetch(:MD502_DEPENDENT_EXEMPTION_COUNT)
                        xml.Amount calculated_fields.fetch(:MD502_DEPENDENT_EXEMPTION_AMOUNT)
                      end
                    end
                  end
                end
                income_section(xml)
                xml.DaytimePhoneNumber @submission.data_source.direct_file_data.phone_number if @submission.data_source.direct_file_data.phone_number.present?
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

            def has_dependent_exemption
              [
                :MD502_DEPENDENT_EXEMPTION_COUNT,
                :MD502_DEPENDENT_EXEMPTION_AMOUNT
              ].any? do |line|
                calculated_fields.fetch(line) > 0
              end
            end

            def has_exemptions
              has_dependent_exemption
            end

            # from MDIndividualeFileTypes.xsd
            FILING_STATUS_OPTIONS = {
              head_of_household: 'HeadOfHousehold',
              married_filing_jointly: 'Joint',
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