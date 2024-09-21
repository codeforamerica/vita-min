module SubmissionBuilder
  module Ty2024
    module States
      module Nc
        module Documents
          class D400 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            FILING_STATUS_OPTIONS = {
              head_of_household: 'HOH',
              married_filing_jointly: 'MFJ',
              married_filing_separately: 'MFS',
              qualifying_widow: 'QW',
              single: "Single",
            }.freeze

            def document
              build_xml_doc("FormNCD400") do |xml|
                xml.ResidencyStatusPrimary true
                xml.ResidencyStatusSpouse true if @submission.data_source.filing_status_mfj?
                xml.VeteranInfoPrimary @submission.data_source.primary_veteran_yes? ? 1 : 0
                if @submission.data_source.filing_status_mfj?
                  xml.VeteranInfoSpouse @submission.data_source.spouse_veteran_yes? ? 1 : 0
                end
                xml.FilingStatus filing_status
                if @submission.data_source.filing_status_mfs?
                  xml.MFSSpouseName @submission.data_source.direct_file_data.spouse_name
                  xml.MFSSpouseSSN @submission.data_source.direct_file_data.spouse_ssn
                end
                if @submission.data_source.filing_status_qw? && @submission.data_source.direct_file_data.spouse_date_of_death.present?
                  xml.QWYearSpouseDied Date.parse(@submission.data_source.direct_file_data.spouse_date_of_death).year
                end
                xml.FAGI @submission.data_source.direct_file_data.fed_agi
                # line 7 AdditionsToFAGI is blank
                xml.FAGIPlusAdditions @submission.data_source.direct_file_data.fed_agi
                # line 9 DeductionsFromFAGI is blank
                xml.NumChildrenAllowed @submission.data_source.direct_file_data.qualifying_children_under_age_ssn_count
                xml.ChildDeduction calculated_fields.fetch(:NCD400_LINE_10B)
                xml.NCStandardDeduction calculated_fields.fetch(:NCD400_LINE_11)
                xml.NCAGIAddition calculated_fields.fetch(:NCD400_LINE_12A)
                xml.NCAGISubtraction calculated_fields.fetch(:NCD400_LINE_12B)
                xml.NCTaxableInc calculated_fields.fetch(:NCD400_LINE_12B) # line 14 = line 12B
                xml.NCIncTax calculated_fields.fetch(:NCD400_LINE_15)
                # line 16 TaxCredits is blank
                xml.SubTaxCredFromIncTax calculated_fields.fetch(:NCD400_LINE_15) # l17 = l15 - l16 and l16 is 0/blank
                xml.IncTaxWith calculated_fields.fetch(:NCD400_LINE_20A)
                xml.IncTaxWithSpouse calculated_fields.fetch(:NCD400_LINE_20B)
                xml.NCTaxPaid calculated_fields.fetch(:NCD400_LINE_23)
                xml.RemainingPayment calculated_fields.fetch(:NCD400_LINE_23) # equal to line 23 bc line 24 not supported
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
