module SubmissionBuilder
  module Ty2024
    module States
      module Id
        module Documents
          class Id40 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            FILING_STATUS_OPTIONS = {
              head_of_household: 'HOH',
              married_filing_jointly: 'JOINT',
              married_filing_separately: 'SEPART',
              qualifying_widow: 'QWID',
              single: "SINGLE",
            }.freeze

            def document
              build_xml_doc("Form40") do |xml|
                xml.FilingStatus filing_status
                add_non_zero_value(xml, :PrimeExemption, :ID40_LINE_6A)
                add_non_zero_value(xml, :SpouseExemption, :ID40_LINE_6B)
                add_non_zero_value(xml, :OtherExemption, :ID40_LINE_6C)
                add_non_zero_value(xml, :TotalExemption, :ID40_LINE_6D)
                @submission.data_source.dependents.each do |dependent|
                  xml.DependentGrid do
                    xml.DependentFirstName sanitize_for_xml(dependent.first_name, 20)
                    xml.DependentLastName sanitize_for_xml(dependent.last_name, 20)
                    unless dependent.ssn.nil?
                      xml.DependentSSN dependent.ssn.delete('-')
                    end
                    xml.DependentDOB date_type(dependent.dob)
                  end
                end
                xml.StateUseTax calculated_fields.fetch(:ID40_LINE_29)
                xml.TaxWithheld calculated_fields.fetch(:ID40_LINE_46)

                xml.WorksheetGroceryCredit calculated_fields.fetch(:ID40_LINE_43_WORKSHEET)
                xml.GroceryCredit calculated_fields.fetch(:ID40_LINE_43)
                xml.DonateGroceryCredit calculated_fields.fetch(:ID40_LINE_43_DONATE)
              end
            end

            private
            def filing_status
              FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
            end

            def calculated_fields
              @calculated_fields ||= @submission.data_source.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end