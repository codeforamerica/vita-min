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
                xml.TaxPeriodBeginDt date_type(Date.new(@submission.data_source.tax_return_year, 1, 1))
                xml.TaxPeriodEndDt date_type(Date.new(@submission.data_source.tax_return_year, 12, 31))
                if @submission.data_source.direct_file_data.claimed_as_dependent?
                  xml.FilingStatus 'DependentTaxpayer'
                else
                  xml.FilingStatus filing_status
                end
                xml.DaytimePhoneNumber @submission.data_source.direct_file_data.phone_number if @submission.data_source.direct_file_data.phone_number.present?
                if @submission.data_source.filing_status_mfs?
                  xml.MFSSpouseSSN @submission.data_source.direct_file_data.spouse_ssn
                end
                xml.Subtractions do
                  xml.ChildAndDependentCareExpenses @submission.data_source.direct_file_data.dependent_care_expenses
                  xml.SocialSecurityRailRoadBenefits  @submission.data_source.direct_file_data.fed_taxable_ssb
                end
              end
            end

            private

            def income_section(root_xml)
              root_xml.Income do |income|
                income.FederalAdjustedGrossIncome calculated_fields.fetch(:MD502_LINE_1)
                income.WagesSalariesAndTips calculated_fields.fetch(:MD502_LINE_1A)
                income.EarnedIncome calculated_fields.fetch(:MD502_LINE_1B)
                income.TaxablePensionsIRAsAnnuities calculated_fields.fetch(:MD502_LINE_1D)
                if calculated_fields.fetch(:MD502_LINE_1E)
                  income.InvestmentIncomeIndicator "X"
                end
              end
            end

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