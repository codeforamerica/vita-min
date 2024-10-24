module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            # from MDIndividualeFileTypes.xsd
            FILING_STATUS_OPTIONS = {
              single: "Single",
              married_filing_jointly: 'Joint',
              married_filing_separately: 'MarriedFilingSeparately',
              head_of_household: 'HeadOfHousehold',
              qualifying_widow: 'QualifyingWidow',
              dependent: 'DependentTaxpayer'
            }.freeze

            def document
              build_xml_doc("Form502", documentId: "Form502") do |xml|
                xml.MarylandSubdivisionCode intake.subdivision_code
                unless intake.political_subdivision&.end_with?("- unincorporated")
                  xml.CityTownOrTaxingArea intake.political_subdivision
                end
                xml.MarylandCounty county_abbreviation
                if intake.direct_file_data.claimed_as_dependent?
                  xml.FilingStatus do
                    xml.DependentTaxpayer "X"
                  end
                elsif intake.filing_status == :married_filing_separately
                  xml.FilingStatus do
                    xml.MarriedFilingSeparately "X", spouseSSN: intake.direct_file_data.spouse_ssn
                  end
                else
                  xml.FilingStatus do
                    xml.send(filing_status, "X")
                  end
                end
                if has_exemptions
                  xml.Exemptions do
                    xml.Primary do
                      xml.Standard calculated_fields.fetch(:MD502_LINE_A_YOURSELF)
                    end
                    if @submission.data_source.filing_status_mfj?
                      xml.Spouse do
                        xml.Standard calculated_fields.fetch(:MD502_LINE_A_SPOUSE)
                      end
                    end
                    xml.Standard do
                      xml.Count calculated_fields.fetch(:MD502_LINE_A_CHECKED_COUNT)
                      xml.amount calculated_fields.fetch(:MD502_LINE_A_AMOUNT)
                    end
                    if has_dependent_exemption
                      xml.Dependents do
                        xml.Count calculated_fields.fetch(:MD502_DEPENDENT_EXEMPTION_COUNT)
                        xml.Amount calculated_fields.fetch(:MD502_DEPENDENT_EXEMPTION_AMOUNT)
                      end
                    end
                  end
                end
                income_section(xml)
                xml.Subtractions do
                  xml.ChildAndDependentCareExpenses @submission.data_source.direct_file_data.total_qualifying_dependent_care_expenses
                  xml.SocialSecurityRailRoadBenefits  @submission.data_source.direct_file_data.fed_taxable_ssb
                end
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

            def filing_status
              FILING_STATUS_OPTIONS[intake.filing_status]
            end

            def county_abbreviation
              COUNTY_ABBREVIATIONS[intake.residence_county]
            end

            COUNTY_ABBREVIATIONS = {
              "Allegany" => "AL",
              "Anne Arundel" => "AA",
              "Baltimore County" => "BL",
              "Baltimore City" => "BC",
              "Calvert" => "CV",
              "Caroline" => "CL",
              "Carroll" => "CR",
              "Cecil" => "CC",
              "Charles" => "CH",
              "Dorchester" => "DR",
              "Frederick" => "FR",
              "Garrett" => "GR",
              "Harford" => "HR",
              "Howard" => "HW",
              "Kent" => "KN",
              "Montgomery" => "MG",
              "Prince George's" => "PG",
              "Queen Anne's" => "QA",
              "St. Mary's" => "SM",
              "Somerset" => "SS",
              "Talbot" => "TB",
              "Washington" => "WH",
              "Wicomico" => "WC",
              "Worcester" => "WR"
            }.freeze
          end
        end
      end
    end
  end
end