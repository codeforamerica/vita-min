module SubmissionBuilder
  module Ty2024
    module States
      module Id
        module Documents
          class Id39R < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form39R") do |xml|
                xml.TotalAdditions calculated_fields.fetch(:ID39R_A_LINE_7)
                xml.IncomeUSObligations calculated_fields.fetch(:ID39R_B_LINE_3)
                xml.ChildCareCreditAmt calculated_fields.fetch(:ID39R_B_LINE_6)
                xml.TxblSSAndRRBenefits calculated_fields.fetch(:ID39R_B_LINE_7)
                xml.PensionFilingStatusAmount calculated_fields.fetch(:ID39R_B_LINE_8a) if Flipper.enabled?(:show_retirement_ui)
                xml.SocialSecurityBenefits calculated_fields.fetch(:ID39R_B_LINE_8c) if Flipper.enabled?(:show_retirement_ui)
                xml.PensionExclusions calculated_fields.fetch(:ID39R_B_LINE_8e) if Flipper.enabled?(:show_retirement_ui)
                xml.RetirementBenefitsDeduction calculated_fields.fetch(:ID39R_B_LINE_8f)
                xml.HealthInsurancePaid calculated_fields.fetch(:ID39R_B_LINE_18)
                xml.TotalSubtractions calculated_fields.fetch(:ID39R_B_LINE_24)
                xml.TotalSupplementalCredits calculated_fields.fetch(:ID39R_D_LINE_4)
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
