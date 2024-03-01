# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        class IndividualReturn < SubmissionBuilder::Document
          DEPENDENT_OVERFLOW_THRESHOLD = 6

          def document
            document = build_xml_doc('ReturnState')
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
            xml_doc = build_xml_doc("processBO") do |xml|
              xml.filingKeys do
                # unclear what SOURCE_CD is, but 61 is implied as the valid value
                xml.SOURCE_CD "61" # https://docs.google.com/spreadsheets/d/16MdzKhIElG90GmC8OI2SsIPIc2CsTeSj/edit#gid=1799047667
                xml.EXT_TP_ID @submission.data_source.primary.ssn if @submission.data_source.primary.ssn.present?
                xml.LIAB_PRD_BEG_DT Date.new(@submission.data_source.tax_return_year).beginning_of_year if @submission.data_source.tax_return_year.present?
                xml.LIAB_PRD_END_DT Date.new(@submission.data_source.tax_return_year).end_of_year if @submission.data_source.tax_return_year.present?
                xml.TAX_YEAR @submission.data_source.tax_return_year if @submission.data_source.tax_return_year.present?
              end

              xml.tiPrime do
                xml.FIRST_NAME @submission.data_source.primary.first_name if @submission.data_source.primary.first_name.present?
                xml.MI_NAME @submission.data_source.primary.middle_initial if @submission.data_source.primary.middle_initial.present?
                xml.LAST_NAME @submission.data_source.primary.last_name if @submission.data_source.primary.last_name.present?
                if @submission.data_source.direct_file_data.mailing_street.present?
                  process_mailing_street(xml)
                end
                xml.MAIL_CITY_ADR @submission.data_source.direct_file_data.mailing_city if @submission.data_source.direct_file_data.mailing_city.present?
                xml.MAIL_STATE_ADR @submission.data_source.direct_file_data.mailing_state if @submission.data_source.direct_file_data.mailing_state.present?
                xml.MAIL_ZIP_5_ADR @submission.data_source.direct_file_data.mailing_zip.slice(0, 5) if @submission.data_source.direct_file_data.mailing_zip.present?
                xml.COUNTY_CD @submission.data_source.county_code if @submission.data_source.county_code.present?
                xml.COUNTY_NAME @submission.data_source.county_name&.truncate(20) if @submission.data_source.county_name.present?
                if @submission.data_source.permanent_street.present?
                  process_permanent_street(xml)
                end
                xml.PERM_CTY_ADR @submission.data_source.permanent_city if @submission.data_source.permanent_city.present?
                xml.PERM_ST_ADR "NY"
                xml.PERM_ZIP_ADR @submission.data_source.permanent_zip if @submission.data_source.permanent_zip.present?
                xml.SCHOOL_CD @submission.data_source.school_district_number if @submission.data_source.school_district_number.present?
                xml.SCHOOL_NAME @submission.data_source.school_district&.truncate(30) if @submission.data_source.school_district.present?
                xml.PR_EMP_DESC @submission.data_source.direct_file_data.primary_occupation[0..24] if @submission.data_source.direct_file_data.primary_occupation.present?
                # We omit country name because we don't support out of country filers
                #xml.COUNTRY_NAME @submission.data_source.mailing_country
              end

              if @submission.data_source.filing_status_mfj?
                xml.tiSpouse do
                  xml.FIRST_NAME @submission.data_source.spouse.first_name if @submission.data_source.spouse.first_name.present?
                  xml.MI_NAME @submission.data_source.spouse.middle_initial if @submission.data_source.spouse.middle_initial.present?
                  xml.LAST_NAME @submission.data_source.spouse.last_name if @submission.data_source.spouse.last_name.present?
                  xml.SP_SSN_NMBR @submission.data_source.spouse.ssn if @submission.data_source.spouse.ssn.present?
                  xml.DCSD_DT @submission.data_source.direct_file_data.spouse_date_of_death if @submission.data_source.spouse_deceased?
                  xml.SP_EMP_DESC @submission.data_source.direct_file_data.spouse_occupation[0..24] if @submission.data_source.direct_file_data.spouse_occupation.present?
                end
              elsif @submission.data_source.filing_status_mfs?
                xml.tiSpouse do
                  xml.SP_SSN_NMBR @submission.data_source.spouse.ssn if @submission.data_source.spouse.ssn.present?
                end
              end

              # These dependents are for NY IT-213
              it_213_qualified_dependents = @submission.data_source.dependents.select(&:eligible_for_child_tax_credit)

              it_213_qualified_dependents.each_with_index do |dependent, index|
                xml.dependent do
                  xml.DEP_SSN_NMBR dependent.ssn if dependent.ssn.present?
                  xml.DEP_SEQ_NMBR index+1
                  xml.DEP_DISAB_IND dependent.eic_disability_yes? ? 1 : 2
                  xml.DEP_FORM_ID 348 # 348 is the code for the IT-213 form
                  xml.DEP_RELATION_DESC dependent.relationship.delete(" ") if dependent.relationship.present?
                  xml.DEP_STUDENT_IND dependent.eic_student_yes? ? 1 : 2
                  xml.DEP_CHLD_LAST_NAME dependent.last_name if dependent.last_name.present?
                  xml.DEP_CHLD_FRST_NAME dependent.first_name if dependent.first_name.present?
                  xml.DEP_CHLD_MI_NAME dependent.middle_initial if dependent.middle_initial.present?
                  xml.DEP_CHLD_SFX_NAME dependent.suffix if dependent.suffix.present?
                  xml.DEP_MNTH_LVD_NMBR dependent.months_in_home if dependent.months_in_home.present?
                  xml.DOB_DT dependent.dob.strftime("%Y-%m-%d") if dependent.dob.present?
                end
              end

              @submission.data_source.dependents.where(eic_qualifying: true).each_with_index do |dependent, index|
                xml.dependent do
                  xml.DEP_SSN_NMBR dependent.ssn if dependent.ssn.present?
                  xml.DEP_SEQ_NMBR index+1
                  unless dependent.eic_disability_unfilled?
                    xml.DEP_DISAB_IND dependent.eic_disability_yes? ? 1 : 2
                  end
                  xml.DEP_FORM_ID 215
                  xml.DEP_RELATION_DESC dependent.relationship.delete(" ") if dependent.relationship.present?
                  unless dependent.eic_student_unfilled?
                    xml.DEP_STUDENT_IND dependent.eic_student_yes? ? 1 : 2
                  end
                  xml.DEP_CHLD_LAST_NAME dependent.last_name if dependent.last_name.present?
                  xml.DEP_CHLD_FRST_NAME dependent.first_name if dependent.first_name.present?
                  xml.DEP_CHLD_MI_NAME dependent.middle_initial if dependent.middle_initial.present?
                  xml.DEP_CHLD_SFX_NAME dependent.suffix if dependent.suffix.present?
                  xml.DEP_MNTH_LVD_NMBR dependent.months_in_home if dependent.months_in_home.present?
                  xml.DOB_DT dependent.dob.strftime("%Y-%m-%d") if dependent.dob.present?
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
            File.join(Rails.root, "vendor", "us_states", "unpacked", "NYSIndividual2023V4.0", "Common", "NysReturnState.xsd")
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
            tax_calculator = @submission.data_source.tax_calculator
            calculated_fields = tax_calculator.calculate
            receiving_213_credit = calculated_fields[:IT213_LINE_14].present? && calculated_fields[:IT213_LINE_14] > 0 && !@submission.data_source.direct_file_data.claimed_as_dependent?
            receiving_214_credit = calculated_fields[:IT214_LINE_33].present? && calculated_fields[:IT214_LINE_33] > 0
            receiving_215_credit = calculated_fields[:IT215_LINE_1].present? && !calculated_fields[:IT215_LINE_2]
            supported_docs = [
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::RtnHeader,
                pdf: nil,
                include: true
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It201,
                pdf: PdfFiller::Ny201Pdf,
                include: true
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It213,
                pdf: PdfFiller::Ny213Pdf,
                include: receiving_213_credit
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It213,
                pdf: PdfFiller::Ny213AttPdf,
                include: @submission.data_source.dependents.select(&:eligible_for_child_tax_credit).length > DEPENDENT_OVERFLOW_THRESHOLD,
                kwargs: { dependent_offset: DEPENDENT_OVERFLOW_THRESHOLD }
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It214,
                pdf: PdfFiller::Ny214Pdf,
                include: receiving_214_credit
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::It215,
                pdf: PdfFiller::Ny215Pdf,
                include: receiving_215_credit
              }
            ]

            @submission.data_source.direct_file_data.w2s.each_with_index do |w2, i|
              intake = @submission.data_source
              intake_w2 = intake.state_file_w2s.find {|w2| w2.w2_index == i } if intake.state_file_w2s.present?

              supported_docs << {
                xml: SubmissionBuilder::Shared::ReturnW2,
                pdf: PdfFiller::NyIt2Pdf,
                include: true,
                kwargs: { w2: w2, intake_w2: intake_w2 }
              }
            end

            @submission.data_source.state_file1099_gs.each do |form1099g|
              supported_docs << {
                xml: SubmissionBuilder::Ty2022::States::Ny::Documents::State1099G,
                pdf: nil,
                include: true,
                kwargs: { form1099g: form1099g }
              }
            end

            supported_docs << {
              xml: nil,
              pdf: PdfFiller::It201AdditionalDependentsPdf,
              include: @submission.data_source.dependents.count >= 8,
            }

            supported_docs
          end
        end
      end
    end
  end
end