module SubmissionBuilder
  module Ty2024
    module States
      module Id
        module Documents
          class Id40 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            FILING_STATUS_OPTIONS = {
              head_of_household: 'HOH',
              married_filing_jointly: 'JOINT',
              married_filing_separately: 'SEPART',
              qualifying_widow: 'QWID',
              single: "SINGLE",
            }.freeze

            def document
              build_xml_doc("Form40") do |xml|
                xml.FilingStatus filing_status
                add_non_zero_value(xml, :PrimeExemption, :ID40_LINE_6A)
                add_non_zero_value(xml, :SpouseExemption, :ID40_LINE_6B)
                add_non_zero_value(xml, :OtherExemption, :ID40_LINE_6C)
                add_non_zero_value(xml, :TotalExemption, :ID40_LINE_6D)
                unless @intake.filing_status_single? && @intake.dependents.count.zero?
                  xml.DependentGrid do
                    xml.DependentFirstName sanitize_for_xml(@intake.primary.first_name, 20)
                    xml.DependentLastName sanitize_for_xml(@intake.primary.last_name, 20)
                    xml.DependentSSN @intake.primary.ssn.delete('-') if @intake.primary.ssn
                    xml.DependentDOB date_type(@intake.primary.birth_date)
                  end
                end
                if @intake.filing_status_mfj?
                  xml.DependentGrid do
                    xml.DependentFirstName sanitize_for_xml(@intake.spouse.first_name, 20)
                    xml.DependentLastName sanitize_for_xml(@intake.spouse.last_name, 20)
                    xml.DependentSSN @intake.spouse.ssn.delete('-') if @intake.spouse.ssn
                    xml.DependentDOB date_type(@intake.spouse.birth_date)
                  end
                end
                @submission.data_source.dependents.each do |dependent|
                  xml.DependentGrid do
                    xml.DependentFirstName sanitize_for_xml(dependent.first_name, 20)
                    xml.DependentLastName sanitize_for_xml(dependent.last_name, 20)
                    unless dependent.ssn.nil?
                      xml.DependentSSN dependent.ssn.delete('-')
                    end
                    xml.DependentDOB date_type(dependent.dob)
                  end
                end
                xml.FederalAGI calculated_fields.fetch(:ID40_LINE_7)
                xml.StateTotalAdjustedIncome calculated_fields.fetch(:ID40_LINE_11)

                if @direct_file_data.primary_over_65 == "X"
                  xml.PrimeOver65 1
                end
                if @intake.filing_status_mfj? && @direct_file_data.spouse_over_65 == "X"
                  xml.SpouseOver65 1
                end

                if @direct_file_data.primary_blind == "X"
                  xml.PrimeBlind 1
                end
                if @intake.filing_status_mfj? && @direct_file_data.spouse_blind == "X"
                  xml.SpouseBlind 1
                end
                if @direct_file_data.primary_claim_as_dependent == "X"
                  xml.ClaimedAsDependent 1
                end

                xml.StandardDeduction calculated_fields.fetch(:ID40_LINE_16)
                xml.TaxableIncomeState calculated_fields.fetch(:ID40_LINE_19)
                xml.StateIncomeTax calculated_fields.fetch(:ID40_LINE_20)
                xml.IdahoChildTaxCredit calculated_fields.fetch(:ID40_LINE_25)
                xml.StateUseTax calculated_fields.fetch(:ID40_LINE_29)
                xml.PermanentBuildingFund calculated_fields.fetch(:ID40_LINE_32A)
                xml.PublicAssistanceIndicator calculated_fields.fetch(:ID40_LINE_32B)
                add_non_zero_value(xml, :TotalTax, :ID40_LINE_33)
                add_non_zero_value(xml, :WildlifeDonation, :ID40_LINE_34)
                add_non_zero_value(xml, :ChildrensTrustDonation, :ID40_LINE_35)
                add_non_zero_value(xml, :SpecialOlympicDonation, :ID40_LINE_36)
                add_non_zero_value(xml, :NationalGuardDonation, :ID40_LINE_37)
                add_non_zero_value(xml, :RedCrossDonation, :ID40_LINE_38)
                add_non_zero_value(xml, :VeteransSupportDonation, :ID40_LINE_39)
                add_non_zero_value(xml, :FoodBankDonation, :ID40_LINE_40)
                add_non_zero_value(xml, :OpportunityScholarshipProgram, :ID40_LINE_41)
                xml.WorksheetGroceryCredit calculated_fields.fetch(:ID40_LINE_43_WORKSHEET)
                xml.GroceryCredit calculated_fields.fetch(:ID40_LINE_43)
                xml.DonateGroceryCredit calculated_fields.fetch(:ID40_LINE_43_DONATE)
                xml.TaxWithheld calculated_fields.fetch(:ID40_LINE_46)
                xml.TaxDue calculated_fields.fetch(:ID40_LINE_51)
                add_element_if_present(xml, "TotalDue", :ID40_LINE_54)
                add_element_if_present(xml, "OverpaymentAfterPenaltyAndInt", :ID40_LINE_55)
                add_element_if_present(xml, "OverpaymentRefunded", :ID40_LINE_56)
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
