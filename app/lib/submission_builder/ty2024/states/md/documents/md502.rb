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
                xml.MarylandSubdivisionCode intake.subdivision_code
                unless intake.political_subdivision == "Baltimore County - unincorporated"
                  xml.CityTownOrTaxingArea intake.political_subdivision
                end
                xml.MarylandCounty county_abbreviation
                if @submission.data_source.direct_file_data.claimed_as_dependent?
                  xml.FilingStatus do
                    xml.DependentTaxpayer "X"
                  end
                else
                  xml.FilingStatus do
                    xml.send(filing_status, "X")
                  end
                end
                income_section(xml)
                xml.DaytimePhoneNumber intake.direct_file_data.phone_number if intake.direct_file_data.phone_number.present?
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