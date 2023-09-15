# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        class IndividualReturn < SubmissionBuilder::Document
          def document
            document = build_xml_doc('efile:ReturnState')
            document.at("ReturnState").add_child(authentication_header)
            document.at("ReturnState").add_child(return_header)
            document.at("ReturnState").add_child("<ReturnDataState></ReturnDataState>")
            document.at("ReturnDataState").add_child(documents_wrapper)
            attached_documents.each do |attached|
              document.at('forms').add_child(document_fragment(attached))
            end
            document
          end

          def self.state_abbreviation
            "NY"
          end

          def self.return_type
            "IT201"
          end

          def pdf_documents
            included_documents.map { |item| item if item.pdf }.compact
          end

          private

          def documents_wrapper
            xml_doc = build_xml_doc("efile:processBO") do |xml|
              xml.filingKeys do
                xml.SOURCE_CD ""
                xml.EXT_TP_ID @submission.data_source.primary.ssn
                xml.LIAB_PRD_BEG_DT Date.new(@submission.data_source.tax_return_year).beginning_of_year
                xml.LIAB_PRD_END_DT Date.new(@submission.data_source.tax_return_year).end_of_year
                xml.TAX_YEAR @submission.data_source.tax_return_year
              end

              xml.tiPrime do
                xml.FIRST_NAME @submission.data_source.primary.first_name
                xml.MI_NAME @submission.data_source.primary.middle_initial
                xml.LAST_NAME @submission.data_source.primary.last_name
                xml.MAIL_LN_2_ADR @submission.data_source.mailing_street
                xml.MAIL_CITY_ADR @submission.data_source.mailing_city
                xml.MAIL_STATE_ADR @submission.data_source.mailing_state
                xml.MAIL_ZIP_5_ADR @submission.data_source.mailing_zip
                xml.COUNTY_CD @submission.data_source.residence_county
                xml.PERM_LN_1_ADR @submission.data_source.permanent_street
                xml.PERM_CTY_ADR @submission.data_source.permanent_city
                xml.PERM_ST_ADR "NY" # TODO: make sure we do want to hardcode this
                xml.PERM_ZIP_ADR @submission.data_source.permanent_zip
                xml.SCHOOL_CD @submission.data_source.school_district_number
                xml.SCHOOL_NAME @submission.data_source.school_district
                xml.COUNTRY_NAME @submission.data_source.mailing_country
              end

              if @submission.data_source.filing_status_married_filing_jointly?
                xml.tiSpouse do
                  xml.FIRST_NAME @submission.data_source.spouse.first_name
                  xml.MI_NAME @submission.data_source.spouse.middle_initial
                  xml.LAST_NAME @submission.data_source.spouse.last_name
                  xml.SP_DOB_DT @submission.data_source.spouse.birth_date
                  xml.SP_SSN_NMBR @submission.data_source.spouse.ssn
                end
              end

              xml.composition do
                xml.forms
              end
            end

            xml_doc.at('*')
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

          def schema_file
            File.join(Rails.root, "vendor", "us_states", "unpacked", "NYSIndividual2022V5.0", "Common", "NysReturnState.xsd")
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
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It201,
                pdf: PdfFiller::Ny201Pdf,
                include: true
              },
            ]
            supported_docs
          end
        end
      end
    end
  end
end