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
              SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2024V0.1", "NJIndividual", "NJForms", "FormNJ1040.xsd")
            end

            def document
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
                          xml.NameSuffix intake.spouse.suffix.upcase if intake.spouse.suffix.present?
                        end
                      end
                    when :qualifying_widow
                      yod = intake.spouse_death_year
                      xml.QualWidOrWider do
                        xml.QualWidOrWiderSurvCuPartner 'X'
                        case yod
                        when (MultiTenantService.new(:statefile).current_tax_year - 1)
                          xml.LastYear 'X'
                        when (MultiTenantService.new(:statefile).current_tax_year - 2)
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
                    if intake.primary_veteran_yes?
                      xml.YouVeteran "X"
                    end
                    if intake.spouse_veteran_yes?
                      xml.SpouseCuPartnerVeteran "X"
                    end
                    if calculated_fields.fetch(:NJ1040_LINE_10_COUNT)&.positive?
                      xml.NumOfQualiDependChild calculated_fields.fetch(:NJ1040_LINE_10_COUNT)
                    end
                    if calculated_fields.fetch(:NJ1040_LINE_11_COUNT)&.positive?
                      xml.NumOfOtherDepend calculated_fields.fetch(:NJ1040_LINE_11_COUNT)
                    end
                    if calculated_fields.fetch(:NJ1040_LINE_12_COUNT)&.positive?
                      xml.DependAttendCollege calculated_fields.fetch(:NJ1040_LINE_12_COUNT)
                    end
                    xml.TotalExemptionAmountA calculated_fields.fetch(:NJ1040_LINE_13)
                  end

                  xml.NjResidentStatusFromDate "#{MultiTenantService.new(:statefile).current_tax_year}-01-01"
                  xml.NjResidentStatusToDate "#{MultiTenantService.new(:statefile).current_tax_year}-12-31"

                  unless intake.dependents.empty?
                    intake.dependents[0..9].each do |dependent|
                      xml.Dependents do
                        xml.DependentsName do
                          xml.FirstName sanitize_for_xml(dependent.first_name)
                          xml.MiddleInitial sanitize_for_xml(dependent.middle_initial) if dependent.middle_initial.present?
                          xml.LastName sanitize_for_xml(dependent.last_name)
                          xml.NameSuffix dependent.suffix.upcase if dependent.suffix.present?
                        end
                        xml.DependentsSSN dependent.ssn
                        xml.BirthYear dependent.dob.year
                        xml.NoHealthInsurance 'X' if dependent.nj_did_not_have_health_insurance_yes?
                      end
                    end
                  end

                  xml.CountyCode "0#{intake.municipality_code}"
                  xml.NactpCode "1963"
                end

                xml.Body do
                  if calculated_fields.fetch(:NJ1040_LINE_15) > 0
                    xml.WagesSalariesTips calculated_fields.fetch(:NJ1040_LINE_15)
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_16A)&.positive?
                    xml.TaxableInterestIncome calculated_fields.fetch(:NJ1040_LINE_16A)
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_16B)&.positive?
                    xml.TaxexemptInterestIncome calculated_fields.fetch(:NJ1040_LINE_16B)
                  end
                  
                  if calculated_fields.fetch(:NJ1040_LINE_27).positive?
                    xml.TotalIncome calculated_fields.fetch(:NJ1040_LINE_27)
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_29).positive?
                    xml.GrossIncome calculated_fields.fetch(:NJ1040_LINE_29)
                  end

                  xml.TotalExemptionAmountB calculated_fields.fetch(:NJ1040_LINE_13)

                  if calculated_fields.fetch(:NJ1040_LINE_31)
                    xml.MedicalExpenses calculated_fields.fetch(:NJ1040_LINE_31)
                  end

                  xml.TotalExemptDeductions calculated_fields.fetch(:NJ1040_LINE_38)

                  if calculated_fields.fetch(:NJ1040_LINE_39).positive?
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
                    elsif intake.household_rent_own_both?
                      xml.Both "X"
                    end

                    if calculated_fields.fetch(:NJ1040_LINE_41)
                      xml.PropertyTaxDeduction calculated_fields.fetch(:NJ1040_LINE_41)
                    end

                    if calculated_fields.fetch(:NJ1040_LINE_56)
                      xml.PropertyTaxCredit calculated_fields.fetch(:NJ1040_LINE_56)
                    end
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_42).positive?
                    xml.NewJerseyTaxableIncome calculated_fields.fetch(:NJ1040_LINE_42)
                  end

                  xml.Tax calculated_fields.fetch(:NJ1040_LINE_43)

                  xml.BalanceOfTaxA calculated_fields.fetch(:NJ1040_LINE_45)
                  xml.TotalCredits calculated_fields.fetch(:NJ1040_LINE_49)
                  xml.BalanceOfTaxAfterCredit calculated_fields.fetch(:NJ1040_LINE_50)

                  xml.SalesAndUseTax calculated_fields.fetch(:NJ1040_LINE_51)

                  if calculated_fields.fetch(:NJ1040_LINE_53C_CHECKBOX)
                    xml.HCCEnclosed "X"
                  end

                  xml.TotalTaxAndPenalty calculated_fields.fetch(:NJ1040_LINE_54)

                  if calculated_fields.fetch(:NJ1040_LINE_55)
                    xml.TaxWithheld calculated_fields.fetch(:NJ1040_LINE_55)
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_57)
                    xml.EstimatedPaymentTotal calculated_fields.fetch(:NJ1040_LINE_57)
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_58).positive?
                    xml.EarnedIncomeCredit do
                      xml.EarnedIncomeCreditAmount calculated_fields.fetch(:NJ1040_LINE_58)
                      xml.EICFederalAmt 'X' if calculated_fields.fetch(:NJ1040_LINE_58_IRS)
                    end
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_59)&.positive?
                    xml.ExcessNjUiWfSwf calculated_fields.fetch(:NJ1040_LINE_59)
                  end

                  if calculated_fields.fetch(:NJ1040_LINE_61)&.positive?
                    xml.ExcesNjFamiInsur calculated_fields.fetch(:NJ1040_LINE_61)
                  end

                  xml.ChildDependentCareCredit calculated_fields.fetch(:NJ1040_LINE_64).to_i if calculated_fields.fetch(:NJ1040_LINE_64)

                  line_65 = calculated_fields.fetch(:NJ1040_LINE_65)
                  xml.NJChildTCNumOfDep calculated_fields.fetch(:NJ1040_LINE_65_DEPENDENTS) if line_65
                  xml.NJChildTaxCredit line_65 if line_65

                  xml.TotalPaymentsOrCredits calculated_fields.fetch(:NJ1040_LINE_66)
                  xml.BalanceDueWithReturn calculated_fields.fetch(:NJ1040_LINE_67)
                  xml.OverpaymentAmount calculated_fields.fetch(:NJ1040_LINE_68)

                  xml.TotalAdjustments calculated_fields.fetch(:NJ1040_LINE_78)
                  xml.NetBalanceDue calculated_fields.fetch(:NJ1040_LINE_79)
                  xml.NetRefund calculated_fields.fetch(:NJ1040_LINE_80)

                  if intake.primary_contribution_gubernatorial_elections_yes?
                    xml.PrimGubernElectFund "X"
                  end

                  if intake.spouse_contribution_gubernatorial_elections_yes?
                    xml.SpouCuPartPrimGubernElectFund "X"
                  end
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