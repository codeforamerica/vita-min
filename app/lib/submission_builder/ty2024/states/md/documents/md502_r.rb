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
                end

                if Flipper.enabled?(:show_md_ssa)
                  add_element_if_present(xml, :PriSSecurityRailRoadBenefits, :MD502R_LINE_9A) if Flipper.enabled?(:show_md_ssa)
                  add_element_if_present(xml, :SecSSecurityRailRoadBenefits, :MD502R_LINE_9B) if Flipper.enabled?(:show_md_ssa)
                end
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