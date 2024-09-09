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
                    xml.CtrbChrtyPrvdAstWrkgPor @calculated_fields.fetch(:AZ322_LINE_20)
                    xml.CtrbMdFePdPblcSchl @calculated_fields.fetch(:AZ301_LINE_7c)
                    xml.TotalAvailTaxCr @calculated_fields.fetch(:AZ301_LINE_26)
                  end
                end
                xml.AppTaxCr do
                  xml.ComputedTax @calculated_fields.fetch(:AZ301_LINE_27)
                  xml.Subtotal 0
                  xml.FamilyIncomeTax @calculated_fields.fetch(:AZ301_LINE_33)
                  xml.DiffFamilyIncTaxSubTotal @calculated_fields.fetch(:AZ301_LINE_34)
                  xml.NonrefunCreditsUsed do
                    xml.CtrbChrtyPrvdAstWrkgPor @calculated_fields.fetch(:AZ301_LINE_40)
                    xml.CtrbMdFePdPblcSchl @calculated_fields.fetch(:AZ301_LINE_41)
                  end
                  xml.TxCrUsedForm301 @calculated_fields.fetch(:AZ301_LINE_62)
                  xml.TotalAvailTaxCrClm @calculated_fields.fetch(:AZ301_LINE_62)
                end
              end
            end
          end
        end
      end
    end
  end
end
