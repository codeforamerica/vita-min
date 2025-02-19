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
              w2s = get_persons_w2s(intake, primary_or_spouse)

              build_xml_doc("FormNJ2450") do |xml|
                w2s.each do |w2|
                  xml.Body do
                    xml.EmployerName get_employer_name(w2, truncate: true)
                    xml.FedEmployerId w2.employer_ein
                    xml.Wages get_wages(w2)
                    xml.Deductions do
                      xml.ColumnA get_column_a(w2)
                      xml.ColumnB 0
                      xml.ColumnC get_column_c(w2)
                    end
                    xml.FilerIndicator filer_indicator
                  end
                end

                xml.ColumnATotal calculated_fields.fetch(line_name("NJ2450_COLUMN_A_TOTAL", primary_or_spouse))
                xml.ColumnBTotal 0
                xml.ColumnCTotal calculated_fields.fetch(line_name("NJ2450_COLUMN_C_TOTAL", primary_or_spouse))
                xml.ColumnAExcess calculated_fields.fetch(line_name("NJ2450_COLUMN_A_EXCESS", primary_or_spouse))
                xml.ColumnBExcess 0
                xml.ColumnCExcess calculated_fields.fetch(line_name("NJ2450_COLUMN_C_EXCESS", primary_or_spouse))
              end
            end

            private
            
            def intake
              @submission.data_source
            end
            
            def calculated_fields
              @nj2450_fields ||= intake.tax_calculator.calculate
            end
            
            def primary_or_spouse
              @kwargs[:primary_or_spouse]
            end

            def filer_indicator
              primary_or_spouse == :primary ? 'T' : 'S'
            end
          end
        end
      end
    end
  end
end