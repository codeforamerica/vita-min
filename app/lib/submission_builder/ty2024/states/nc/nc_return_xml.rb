# frozen_string_literal: true
module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        class NcReturnXml < SubmissionBuilder::StateReturn
          FILING_STATUS_OPTIONS = {
            head_of_household: 'HOH',
            married_filing_jointly: 'MFJ',
            married_filing_separately: 'MFS',
            qualifying_widow: 'QW',
            single: "Single",
          }.freeze

          STANDARD_DEDUCTIONS = {
            head_of_household: 19125,
            married_filing_jointly: 25500,
            married_filing_separately: 12750,
            qualifying_widow: 25500,
            single: 12750,
          }.freeze

          private

          def build_xml_doc_tag
            "efile:ReturnState"
          end

          def attached_documents_parent_tag
            "ReturnDataState"
          end

          def state_schema_version
            "NCIndividual2023v1.0"
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "NCIndividual2023v1.0", "NCIndividual", "IndividualReturnNCD400.xsd")
          end

          def supported_documents
            [
              {
                xml: nil,
                pdf: PdfFiller::NcD400Pdf,
                include: true
              },
            ]
          end

          def documents_wrapper
            xml_doc = build_xml_doc("FormNCD400") do |xml|
              xml.ResidencyStatusPrimary true
              xml.ResidencyStatusSpouse true if @submission.data_source.filing_status_mfj?
              xml.FilingStatus filing_status
              if @submission.data_source.filing_status_mfs?
                xml.MFSSpouseName @submission.data_source.direct_file_data.spouse_name
                xml.MFSSpouseSSN @submission.data_source.direct_file_data.spouse_ssn
              end
              if @submission.data_source.filing_status_qw?
                xml.QWYearSpouseDied Date.parse(@submission.data_source.direct_file_data.spouse_date_of_death).year
              end
              xml.FAGI @submission.data_source.direct_file_data.fed_agi
              xml.NCStandardDeduction standard_deduction
            end
            xml_doc.at('*')
          end

          def filing_status
            FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
          end

          def standard_deduction
            STANDARD_DEDUCTIONS[@submission.data_source.filing_status]
          end
        end
      end
    end
  end
end