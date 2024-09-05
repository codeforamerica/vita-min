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

            def document
              qualifying_dependents = @submission.qualifying_dependents
              
              build_xml_doc("FormNJ1040") do |xml|
                xml.Header do
                  xml.FilingStatus do
                    status = intake.filing_status.to_sym
                    case status
                    when :married_filing_separately
                      xml.MarriedCuPartFilingSeparate do
                        xml.SpouseSSN intake.spouse_ssn
                        xml.SpouseName do
                          xml.FirstName sanitize_for_xml(intake.spouse_first_name)
                          xml.MiddleInitial sanitize_for_xml(intake.spouse_middle_initial) if intake.spouse_middle_initial.present?
                          xml.LastName sanitize_for_xml(intake.spouse_last_name)
                          xml.NameSuffix intake.spouse_suffix if intake.spouse_suffix.present?
                        end
                      end
                    when :qualifying_widow
                      yod = Date.parse(@submission.data_source.direct_file_data.spouse_date_of_death)&.strftime("%Y")
                      xml.QualWidOrWider do
                        xml.QualWidOrWiderSurvCuPartner 'X'
                        if yod == Time.now.year - 1
                          xml.LastYear 'X'
                        elsif yod == Time.now.year - 2
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
                    xml.NumOfQualiDependChild qualifying_dependents.count(&:qualifying_child?)
                    xml.NumOfOtherDepend qualifying_dependents.count(&:qualifying_relative?)
                  end

                  unless intake.dependents.empty?
                    xml.Dependents do
                      # TODO: Should this be qualifying dependents? Or all dependents?
                      intake.dependents.each do |dependent|
                        xml.DependentsName do 
                          xml.FirstName sanitize_for_xml(dependent.first_name)
                          xml.MiddleInitial sanitize_for_xml(dependent.middle_initial) if dependent.middle_initial.present?
                          xml.LastName sanitize_for_xml(dependent.last_name)
                          xml.NameSuffix dependent.suffix if dependent.suffix.present?
                        end
                        xml.DependentsSSN dependent.ssn
                      end
                    end
                  end
                end
                
                xml.Body do
                  xml.TaxableInterestIncome intake.fed_taxable_income
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