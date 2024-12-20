module SubmissionBuilder
  module Ty2022
    module States
      module Az
        module Documents
          class Az301 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods
            def document
              @calculated_fields ||= @submission.data_source.tax_calculator.calculate

              build_xml_doc("Form301") do |xml|
                xml.NonRfndTaxCr do
                  xml.ColumnA do
                    xml.CtrbChrtyPrvdAstWrkgPor @calculated_fields.fetch(:AZ301_LINE_6a)
                    xml.CtrbMdFePdPblcSchl @calculated_fields.fetch(:AZ301_LINE_7a)
                  end
                  xml.ColumnC do
                    xml.CtrbChrtyPrvdAstWrkgPor @calculated_fields.fetch(:AZ301_LINE_6c)
                    xml.CtrbMdFePdPblcSchl @calculated_fields.fetch(:AZ301_LINE_7c)
                    xml.TotalAvailTaxCr @calculated_fields.fetch(:AZ301_LINE_25)
                  end
                end
                xml.AppTaxCr do
                  xml.ComputedTax @calculated_fields.fetch(:AZ301_LINE_26)
                  xml.Subtotal @calculated_fields.fetch(:AZ301_LINE_31)
                  xml.FamilyIncomeTax @calculated_fields.fetch(:AZ301_LINE_32)
                  xml.DiffFamilyIncTaxSubTotal @calculated_fields.fetch(:AZ301_LINE_33)
                  xml.NonrefunCreditsUsed do
                    xml.CtrbChrtyPrvdAstWrkgPor @calculated_fields.fetch(:AZ301_LINE_39)
                    xml.CtrbMdFePdPblcSchl @calculated_fields.fetch(:AZ301_LINE_40)
                  end
                  xml.TxCrUsedForm301 @calculated_fields.fetch(:AZ301_LINE_60)
                  xml.TotalAvailTaxCrClm @calculated_fields.fetch(:AZ301_LINE_60)
                end
              end
            end
          end
        end
      end
    end
  end
end
