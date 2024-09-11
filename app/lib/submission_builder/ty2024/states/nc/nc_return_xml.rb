# frozen_string_literal: true
module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        class NcReturnXml < SubmissionBuilder::StateReturn
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

          def documents_wrapper
            xml_doc = build_xml_doc("FormNCD400") do |xml|
              xml.ResidencyStatusPrimary true
              xml.ResidencyStatusSpouse true if @submission.data_source.filing_status_mfj?
              xml.VeteranInfoPrimary @submission.data_source.primary_veteran_yes? ? 1 : 2
              if @submission.data_source.filing_status_mfj?
                xml.VeteranInfoSpouse @submission.data_source.spouse_veteran_yes? ? 1 : 2
              end
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
          
          def supported_documents
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2024::States::Nc::Documents::D400,
                pdf: PdfFiller::NcD400Pdf,
                include: true
              },
            ]

            supported_docs += combined_w2s

            supported_docs
          end
        end
      end
    end
  end
end