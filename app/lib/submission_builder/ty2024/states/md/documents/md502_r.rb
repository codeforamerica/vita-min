# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md502R < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form502R", documentId: "Form502R") do |xml|
                xml.PrimaryAge @intake.calculate_age(@intake.primary_birth_date, inclusive_of_jan_1: false)
                xml.SecondaryAge @intake.calculate_age(@intake.spouse_birth_date, inclusive_of_jan_1: false) if @intake.filing_status_mfj?
                if Flipper.enabled?(:show_retirement_ui)
                  add_element_if_present(xml, :PriTotalPermDisabledIndicator, :MD502R_LINE_PRIMARY_DISABLED)
                  add_element_if_present(xml, :SecTotalPermDisabledIndicator, :MD502R_LINE_SPOUSE_DISABLED)
                  xml.SourceRetirementIncome do
                    xml.PrimaryTaxpayer do
                      add_element_if_present(xml, :EmployeeRetirementSystem, :MD502R_LINE_1A)
                      add_element_if_present(xml, :OtherAndForeign, :MD502R_LINE_7A)
                    end

                    if @intake.filing_status_mfj?
                      xml.SecondaryTaxpayer do
                        add_element_if_present(xml, :EmployeeRetirementSystem, :MD502R_LINE_1B)
                        add_element_if_present(xml, :OtherAndForeign, :MD502R_LINE_7B)
                      end
                    end
                    add_element_if_present(xml, :TotalPensionsIRAsAnnuities, :MD502R_LINE_8)
                  end
                end

                add_element_if_present(xml, :PriSSecurityRailRoadBenefits, :MD502R_LINE_9A)
                add_element_if_present(xml, :PriMilLawEnforceIncSub, :MD502R_LINE_10A) if Flipper.enabled?(:show_retirement_ui)
                add_element_if_present(xml, :SecSSecurityRailRoadBenefits, :MD502R_LINE_9B)
                add_element_if_present(xml, :SecMilLawEnforceIncSub, :MD502R_LINE_10B) if Flipper.enabled?(:show_retirement_ui)
                add_element_if_present(xml, :PriPensionExclusion, :MD502R_LINE_11A) if Flipper.enabled?(:show_retirement_ui)
                add_element_if_present(xml, :SecPensionExclusion, :MD502R_LINE_11B) if Flipper.enabled?(:show_retirement_ui)
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @md502_r_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end