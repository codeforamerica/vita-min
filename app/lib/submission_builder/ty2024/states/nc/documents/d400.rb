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
              phone_number = PhoneParser.e164_to_raw_phone_number(@submission.data_source.phone_number) || @submission.data_source.direct_file_data.phone_number

              build_xml_doc("FormNCD400") do |xml|
                xml.NCCountyCode @submission.data_source.residence_county
                xml.OutOfCountry "X" if Flipper.enabled?(:extension_period) && @submission.data_source.out_of_country_yes?
                xml.ResidencyStatusPrimary true
                xml.ResidencyStatusSpouse true if @submission.data_source.filing_status_mfj?
                xml.VeteranInfoPrimary @submission.data_source.primary_veteran_yes? ? 1 : 0
                if @submission.data_source.filing_status_mfj?
                  xml.VeteranInfoSpouse @submission.data_source.spouse_veteran_yes? ? 1 : 0
                end
                if Flipper.enabled?(:extension_period) && @submission.data_source.paid_federal_extension_payments_yes?
                  xml.FederalExtension 1
                else
                  xml.FederalExtension 0
                end
                xml.FilingStatus filing_status
                if @submission.data_source.filing_status_mfs?
                  xml.MFSSpouseName do
                    xml.FirstName sanitize_for_xml(@submission.data_source.spouse.first_name, 16) if @submission.data_source.spouse.first_name.present?
                    xml.MiddleInitial sanitize_middle_initial(@submission.data_source.spouse.middle_initial) if sanitize_middle_initial(@submission.data_source.spouse.middle_initial).present?
                    xml.LastName sanitize_for_xml(@submission.data_source.spouse.last_name, 32) if @submission.data_source.spouse.last_name.present?
                  end
                  unless @submission.data_source.direct_file_data.non_resident_alien == "NRA"
                    xml.MFSSpouseSSN @submission.data_source.direct_file_data.spouse_ssn if @submission.data_source.direct_file_data.spouse_ssn.present?
                  end
                end
                if @submission.data_source.filing_status_qw? && @submission.data_source.spouse_death_year.present?
                  xml.QWYearSpouseDied @submission.data_source.spouse_death_year
                end
                xml.FAGI calculated_fields.fetch(:NCD400_LINE_6)
                # line 7 AdditionsToFAGI is blank
                xml.FAGIPlusAdditions @submission.data_source.direct_file_data.fed_agi
                xml.DeductionsFromFAGI calculated_fields.fetch(:NCD400_LINE_9) if calculated_fields.fetch(:NCD400_LINE_9).positive? 
                xml.NumChildrenAllowed @submission.data_source.direct_file_data.qualifying_children_under_age_ssn_count if @submission.data_source.direct_file_data.qualifying_children_under_age_ssn_count.present?
                xml.ChildDeduction calculated_fields.fetch(:NCD400_LINE_10B)
                xml.NCStandardDeduction calculated_fields.fetch(:NCD400_LINE_11)
                xml.NCAGIAddition calculated_fields.fetch(:NCD400_LINE_12A)
                xml.NCAGISubtraction calculated_fields.fetch(:NCD400_LINE_12B)
                xml.NCTaxableInc calculated_fields.fetch(:NCD400_LINE_14)
                xml.NCIncTax calculated_fields.fetch(:NCD400_LINE_17)
                xml.SubTaxCredFromIncTax calculated_fields.fetch(:NCD400_LINE_15) # l17 = l15 - l16 and l16 is 0/blank
                # line 16 TaxCredits is blank
                xml.UseTax calculated_fields.fetch(:NCD400_LINE_18)
                if @submission.data_source.untaxed_out_of_state_purchases_no?
                  xml.NoUseTaxDue 'X'
                end
                xml.TotalNCTax calculated_fields.fetch(:NCD400_LINE_19)
                xml.IncTaxWith calculated_fields.fetch(:NCD400_LINE_20A)
                xml.IncTaxWithSpouse calculated_fields.fetch(:NCD400_LINE_20B)
                xml.PdWithExt calculated_fields.fetch(:NCD400_LINE_21B) if Flipper.enabled?(:extension_period) && !calculated_fields.fetch(:NCD400_LINE_21B).zero?
                xml.NCTaxPaid calculated_fields.fetch(:NCD400_LINE_23)
                xml.RemainingPayment calculated_fields.fetch(:NCD400_LINE_23) # equal to line 23 bc line 24 not supported
                if calculated_fields.fetch(:NCD400_LINE_26A).present?
                  xml.TaxDue calculated_fields.fetch(:NCD400_LINE_26A)
                end
                xml.TotalAmountDue calculated_fields.fetch(:NCD400_LINE_27)
                if calculated_fields.fetch(:NCD400_LINE_28).present?
                  xml.Overpayment calculated_fields.fetch(:NCD400_LINE_28)
                end
                xml.RefundAmt calculated_fields.fetch(:NCD400_LINE_34)
                if (@submission.data_source.withdraw_amount || 0).positive? # OWE
                  xml.PaymentContact do
                    xml.PersonName do
                      xml.FirstName sanitize_for_xml(@submission.data_source.primary.first_name, 16) if @submission.data_source.primary.first_name.present?
                      xml.MiddleInitial sanitize_middle_initial(@submission.data_source.primary.middle_initial) if sanitize_middle_initial(@submission.data_source.primary.middle_initial).present?
                      xml.LastName sanitize_for_xml(@submission.data_source.primary.last_name, 32) if @submission.data_source.primary.last_name.present?
                      xml.NameSuffix @submission.data_source.primary.suffix.upcase if @submission.data_source.primary.suffix.present?
                    end
                    xml.USPhoneNumber phone_number if phone_number
                  end
                end
              end
            end

            private

            def filing_status
              FILING_STATUS_OPTIONS[@submission.data_source.state_filing_status]
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
