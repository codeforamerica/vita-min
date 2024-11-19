# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        module Documents
          class Nj2450 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods
            include StateFile::Nj2450Helper

            def schema_file
              SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2024V0.1", "NJCommon", "FormNJ2450.xsd")
            end

            def document
              build_xml_doc("FormNJ2450") do |xml|
                persons_w2s.each do |w2|
                  xml.Body do
                    column_a = w2.box14_ui_wf_swf&.positive? ? w2.box14_ui_wf_swf : w2.box14_ui_hc_wd

                    xml.EmployerName w2.employer_name
                    xml.FedEmployerId w2.employer_ein
                    xml.Wages w2.wages&.round
                    xml.Deductions do
                      xml.ColumnA column_a&.round || 0
                      xml.ColumnB 0
                      xml.ColumnC w2.box14_fli&.round || 0
                    end
                    xml.FilerIndicator filer_indicator
                  end
                end

                xml.ColumnATotal calculated_fields.fetch(line_name("NJ2450_COLUMN_A_TOTAL", person.primary_or_spouse))
                xml.ColumnBTotal 0
                xml.ColumnCTotal calculated_fields.fetch(line_name("NJ2450_COLUMN_C_TOTAL", person.primary_or_spouse))
                xml.ColumnAExcess calculated_fields.fetch(line_name("NJ2450_COLUMN_A_EXCESS", person.primary_or_spouse))
                xml.ColumnBExcess 0
                xml.ColumnCExcess calculated_fields.fetch(line_name("NJ2450_COLUMN_C_EXCESS", person.primary_or_spouse))
              end
            end

            private
            
            def intake
              @submission.data_source
            end
            
            def calculated_fields
              @nj2450_fields ||= intake.tax_calculator.calculate
            end
            
            def person
              @kwargs[:person]
            end

            def persons_w2s
              intake.state_file_w2s.all&.select { |w2| w2.employee_ssn == person.ssn }
            end

            def filer_indicator
              person.primary_or_spouse == :primary ? 'T' : 'S'
            end
          end
        end
      end
    end
  end
end