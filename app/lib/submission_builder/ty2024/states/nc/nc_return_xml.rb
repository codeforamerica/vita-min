# frozen_string_literal: true
module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        class NcReturnXml < SubmissionBuilder::StateReturn
          FILING_STATUS_OPTIONS = {
            :married_filing_jointly => 'MFJ',
            :married_filing_separately => 'MFS',
            :single => "Single",
            :head_of_household => 'HOH',
            :qualifying_widow => 'QW'
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

          def documents_wrapper
            xml_doc = build_xml_doc("FormNCD400") do |xml|
              xml.ResidencyStatusPrimary true
              xml.ResidencyStatusSpouse true if @submission.data_source.filing_status_mfj?
              xml.FilingStatus filing_status
              xml.FAGI @submission.data_source.direct_file_data.fed_agi
            end
            xml_doc.at('*')
          end

          def supported_documents
            combined_w2s
          end

          def filing_status
            FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
          end
        end
      end
    end
  end
end