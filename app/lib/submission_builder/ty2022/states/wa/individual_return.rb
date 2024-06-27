# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Wa
        class IndividualReturn < SubmissionBuilder::Document
          FILING_STATUS_OPTIONS = {
            :married_filing_jointly => 'MarriedJoint',
            :head_of_household => 'HeadHousehold',
            :married_filing_separately => 'MarriedFilingSeparateReturn',
            :single => "Single"
          }

          STANDARD_DEDUCTIONS = {
            single: 12950,
            married_filing_jointly: 25900,
            married_filing_separately: 12950,
            head_of_household: 19400,
          }.freeze

          # TODO: centralize reference to state schema version
          def document
            document = build_xml_doc('efile:ReturnState', stateSchemaVersion: "WAIndividual2023v1.0")
            # document.at("ReturnState").add_child(authentication_header)
            document.at("ReturnState").add_child(return_header)
            document.at("ReturnState").add_child("<ReturnDataState></ReturnDataState>")
            document.at("ReturnDataState").add_child(documents_wrapper)
            attached_documents.each do |attached|
              document.at('ReturnDataState').add_child(document_fragment(attached))
            end
            document
          end

          # TODO: get state abbreviation from state info service
          def self.state_abbreviation
            "WA"
          end

          # TODO: put return type in info service?
          def self.return_type
            "Phorm1000"
          end

          def pdf_documents
            included_documents.map { |item| item if item.pdf }.compact
          end

          private

          def documents_wrapper
            # TODO: don't hardcode return type string
            xml_doc = build_xml_doc("Phorm1000") do |xml|
              xml.FilingStatus filing_status
              if calculated_fields[:WA100_LINE_1].positive?
                xml.RefundAmt calculated_fields.fetch(:WA100_LINE_1)
              else
                xml.AmtOwed calculated_fields.fetch(:WA100_LINE_2)
              end
            end
            xml_doc.at('*')
          end

          def filing_status
            FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
          end

          def document_fragment(document)
            document[:xml_class].build(@submission, validate: false, kwargs: document[:kwargs]).document.at("*")
          end

          def authentication_header
            SubmissionBuilder::Ty2022::States::AuthenticationHeader.build(@submission, validate: false).document.at("*")
          end

          def return_header
            SubmissionBuilder::Ty2022::States::ReturnHeader.build(@submission, validate: false).document.at("*")
          end

          # TODO: also put schema file in state info service?
          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "WAIndividual2023v1.0", "WAIndividual", "IndividualReturnWA1000.xsd")
          end

          def attached_documents
            @attached_documents ||= xml_documents.map { |doc| { xml_class: doc.xml, kwargs: doc.kwargs } }
          end

          def xml_documents
            included_documents.map { |item| item if item.xml }.compact
          end

          def included_documents
            supported_documents.map { |item| OpenStruct.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }.compact
          end

          def supported_documents
            supported_docs = [
              {
                xml: nil,
                pdf: PdfFiller::Wa1000Pdf,
                include: true
              }
            ]

            # @submission.data_source.direct_file_data.w2s.each_with_index do |w2, i|
            #   intake = @submission.data_source
            #   intake_w2 = intake.state_file_w2s.find {|w2| w2.w2_index == i } if intake.state_file_w2s.present?
            #
            #   supported_docs << {
            #     xml: SubmissionBuilder::Shared::ReturnW2,
            #     pdf: nil,
            #     include: true,
            #     kwargs: { w2: w2, intake_w2: intake_w2 }
            #   }
            # end

            supported_docs
          end

          def calculated_fields
            @submission.data_source.tax_calculator.calculate
          end
        end
      end
    end
  end
end