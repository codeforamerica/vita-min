# frozen_string_literal: true

module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        module Documents
          class Nj1040 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            FILING_STATUS_ELEMENT = {
              :married_filing_jointly => "MarriedCuPartFilingJoint",
              :head_of_household => "HeadOfHousehold",
              :married_filing_separately => "MarriedCuPartFilingSeparate",
              :single => "Single",
              :qualifying_widow => "QualWidOrWider"
            }.freeze

            def schema_file
              SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2023V0.4", "NJIndividual", "NJForms", "FormNJ1040.xsd")
            end

            def document
              qualifying_dependents = @submission.qualifying_dependents
              
              build_xml_doc("FormNJ1040") do |xml|
                xml.Header do
                  xml.FilingStatus do
                    status = intake.filing_status.to_sym
                    case status
                    when :married_filing_separately
                      xml.MarriedCuPartFilingSeparate do
                        xml.SpouseSSN intake.spouse.ssn
                        xml.SpouseName do
                          xml.FirstName sanitize_for_xml(intake.spouse.first_name)
                          xml.MiddleInitial sanitize_for_xml(intake.spouse.middle_initial) if intake.spouse.middle_initial.present?
                          xml.LastName sanitize_for_xml(intake.spouse.last_name)
                          xml.NameSuffix intake.spouse.suffix if intake.spouse.suffix.present?
                        end
                      end
                    when :qualifying_widow
                      yod = Date.parse(intake.direct_file_data.spouse_date_of_death)&.strftime("%Y")
                      xml.QualWidOrWider do
                        xml.QualWidOrWiderSurvCuPartner 'X'
                        case yod
                        when MultiTenantService.new(:statefile).current_tax_year.to_s
                          xml.LastYear 'X'
                        when (MultiTenantService.new(:statefile).current_tax_year - 1).to_s
                          xml.TwoYearPrior 'X'
                        end
                      end
                    when :single, :married_filing_jointly, :head_of_household
                      xml.send(FILING_STATUS_ELEMENT[status], 'X')
                    else
                      raise "Filing status not found"
                    end
                  end

                  xml.Exemptions do
                    xml.YouRegular "X"
                    if calculated_fields.fetch(:NJ1040_LINE_6_SPOUSE)
                      xml.SpouseCuRegular "X"
                    end
                    if calculated_fields.fetch(:NJ1040_LINE_7_SELF)
                      xml.YouOver65 "X"
                    end
                    if calculated_fields.fetch(:NJ1040_LINE_7_SPOUSE)
                      xml.SpouseCuPartner65OrOver "X"
                    end
                    if @submission.data_source.direct_file_data.is_primary_blind? || intake.primary_disabled_yes?
                      xml.YouBlindOrDisabled "X"
                    end
                    if @submission.data_source.direct_file_data.is_spouse_blind? || intake.spouse_disabled_yes?
                      xml.SpouseCuPartnerBlindOrDisabled "X"
                    end
                    xml.NumOfQualiDependChild qualifying_dependents.count(&:qualifying_child?)
                    xml.NumOfOtherDepend qualifying_dependents.count(&:qualifying_relative?)
                    xml.TotalExemptionAmountA calculated_fields.fetch(:NJ1040_LINE_13)
                  end

                  unless intake.dependents.empty?
                    intake.dependents[0..9].each do |dependent|
                      xml.Dependents do
                        xml.DependentsName do
                          xml.FirstName sanitize_for_xml(dependent.first_name)
                          xml.MiddleInitial sanitize_for_xml(dependent.middle_initial) if dependent.middle_initial.present?
                          xml.LastName sanitize_for_xml(dependent.last_name)
                          xml.NameSuffix dependent.suffix if dependent.suffix.present?
                        end
                        xml.DependentsSSN dependent.ssn
                        xml.BirthYear dependent.dob.year
                      end
                    end
                  end

                  xml.CountyCode "0#{intake.municipality_code}"
                  xml.NactpCode "1234567890" # TODO: - placeholder value
                end

                xml.Body do
                  if calculated_fields.fetch(:NJ1040_LINE_15) >= 0
                    xml.WagesSalariesTips calculated_fields.fetch(:NJ1040_LINE_15)
                  end
                  if calculated_fields.fetch(:NJ1040_LINE_27) > 0
                    xml.TotalIncome calculated_fields.fetch(:NJ1040_LINE_27)
                  end
                  if calculated_fields.fetch(:NJ1040_LINE_29) > 0
                    xml.GrossIncome calculated_fields.fetch(:NJ1040_LINE_29)
                  end

                  xml.TotalExemptionAmountB calculated_fields.fetch(:NJ1040_LINE_13)
                  xml.TotalExemptDeductions calculated_fields.fetch(:NJ1040_LINE_38)

                  if calculated_fields.fetch(:NJ1040_LINE_39) > 0
                    xml.TaxableIncome calculated_fields.fetch(:NJ1040_LINE_39)
                  end

                  xml.PropertyTaxDeductOrCredit do
                    if calculated_fields.fetch(:NJ1040_LINE_40A)
                      xml.TotalPropertyTaxPaid calculated_fields.fetch(:NJ1040_LINE_40A)
                    end

                    if intake.household_rent_own_rent?
                      xml.Tenant "X"
                    elsif intake.household_rent_own_own?
                      xml.Homeowner "X"
                    end

                    if calculated_fields.fetch(:NJ1040_LINE_41)
                      xml.PropertyTaxCredit calculated_fields.fetch(:NJ1040_LINE_41)
                    end

                    if calculated_fields.fetch(:NJ1040_LINE_56)
                      xml.PropertyTaxDeduction calculated_fields.fetch(:NJ1040_LINE_56)
                    end
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_42) > 0
                    xml.NewJerseyTaxableIncome calculated_fields.fetch(:NJ1040_LINE_42)
                  end

                  xml.Tax calculated_fields.fetch(:NJ1040_LINE_43)

                  xml.ChildDependentCareCredit calculated_fields.fetch(:NJ1040_LINE_64).to_i if calculated_fields.fetch(:NJ1040_LINE_64)

                  line_65 = calculated_fields.fetch(:NJ1040_LINE_65)
                  xml.NJChildTCNumOfDep calculated_fields.fetch(:NJ1040_LINE_65_DEPENDENTS) if line_65
                  xml.NJChildTaxCredit line_65 if line_65
                end
              end
            end

            private

            def intake
              @submission.data_source
            end

            def calculated_fields
              @nj1040_fields ||= intake.tax_calculator.calculate
            end
          end
        end
      end
    end
  end
end