# frozen_string_literal: true
module SubmissionBuilder
  module Ty2022
    module States
      module Az
        class IndividualReturn < SubmissionBuilder::Document
          FILING_STATUSES = {
            single: 'Single',
            married_filing_jointly: 'MarriedJoint',
            married_filing_separately: 'MarriedFilingSeparateReturn',
            head_of_household: 'HeadHousehold',
          }.freeze
          STANDARD_DEDUCTIONS = {
            single: 12950,
            married_filing_jointly: 25900,
            married_filing_separately: 12950,
            head_of_household: 19400,
          }.freeze

          def document
            document = build_xml_doc('efile:ReturnState', stateSchemaVersion: "AZIndividual2023v1.0")
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
            "AZ"
          end

          def self.return_type
            "Form140"
          end

          def pdf_documents
            included_documents.map { |item| item if item.pdf }.compact
          end

          private

          def documents_wrapper
            xml_doc = build_xml_doc("Form140") do |xml|
              xml.LNPriorYrs @submission.data_source.prior_last_names
              xml.FilingStatus filing_status
              xml.Exemptions do
                xml.AgeExemp calculated_fields.fetch(:AZ140_LINE_8)
                xml.VisionExemp calculated_fields.fetch(:AZ140_LINE_9)
                xml.DependentsUnder17 calculated_fields.fetch(:AZ140_LINE_10A)
                xml.Dependents17AndOlder calculated_fields.fetch(:AZ140_LINE_10B)
                xml.QualifyingParentsAncestors calculated_fields.fetch(:AZ140_LINE_11A)
              end # TODO fix after we figure out dependent information
              xml.SupplementPageAttached 'X' # TODO Check box if theres not enough space on the first page for dependents
              xml.Dependents do
                @submission.data_source.dependents.each do |dependent|
                  xml.DependentDetails do
                    xml.Name do
                      xml.FirstName dependent.first_name
                      xml.MiddleInitial dependent.middle_initial if dependent.middle_initial.present? # TODO: we may not have this from DF, might have to ask the client for i
                      xml.LastName dependent.last_name
                    end
                    unless dependent.ssn.nil?
                      xml.DependentSSN dependent.ssn.delete('-')
                    end
                    xml.RelationShip dependent.relationship
                    xml.NumMonthsLived dependent.months_in_home
                    if dependent.dob > 17.years.ago # TODO: needs to be based on a specific tax year date, also assumes we will have dob at all
                      xml.DepUnder17 'X'
                    else
                      xml.Dep17AndOlder 'X'
                    end
                  end
                end
                @submission.data_source.dependents.select(&:ask_senior_questions?).each do |dependent|
                  xml.QualParentsAncestors do
                    xml.Name do
                      xml.FirstName dependent.first_name
                      xml.MiddleInitial dependent.middle_initial if dependent.middle_initial.present? # TODO: we may not have this from DF, might have to ask the client for i
                      xml.LastName dependent.last_name
                    end
                    unless dependent.ssn.nil?
                      xml.DependentSSN dependent.ssn.delete('-')
                    end
                    xml.RelationShip dependent.relationship
                    xml.NumMonthsLived dependent.months_in_home
                    if dependent.dob <= 65.years.ago # TODO: needs to be based on a specific tax year date, also assumes we will have dob at all
                      xml.IsOverSixtyFive 'X'
                    end
                    if dependent.passed_away_yes?
                      xml.DiedInTaxYear 'X'
                    end
                  end
                end
                # TODO dependents must be partitioned into DependentDetails and QualParentsAncestors based on relationship and possibly other factors
              end
              xml.Additions do
                xml.FedAdjGrossIncome calculated_fields.fetch(:AZ140_LINE_12)
                xml.ModFedAdjGrossInc calculated_fields.fetch(:AZ140_LINE_14)
              end
              xml.AzAdjSubtotal calculated_fields.fetch(:AZ140_LINE_19)
              xml.Subtractions do
                xml.USSSRailRoadBnft calculated_fields.fetch(:AZ140_LINE_30)
              end
              xml.TotalSubtractions calculated_fields.fetch(:AZ140_LINE_35)
              xml.Subtotal calculated_fields.fetch(:AZ140_LINE_37)
              xml.AzSubtrAmts do
                xml.ExemAmtAge65OrOver calculated_fields.fetch(:AZ140_LINE_38)
                xml.ExemAmtBlind calculated_fields.fetch(:AZ140_LINE_39)
                xml.ExemAmtParentsAncestors calculated_fields.fetch(:AZ140_LINE_41)
              end
              xml.AZAdjGrossIncome calculated_fields.fetch(:AZ140_LINE_42)
              xml.DeductionAmt do
                xml.DeductionTypeIndc 'Standard' # todo: we only support standard tho 43S
                xml.AZDeductions calculated_fields.fetch(:AZ140_LINE_43)

                xml.ClaimCharitableDed do
                  #calculated_fields.fetch(:AZ140_LINE_44)
                  xml.CharitableDeduction "X"
                  xml.IncStdCharitableDed 2
                  xml.IncreaseStdDed do
                    xml.GiftByCashOrCheck calculated_fields.fetch(:AZ140_CCWS_LINE_1c)
                    xml.OtherThanCashOrCheck calculated_fields.fetch(:AZ140_CCWS_LINE_2c)
                    xml.CarrPriorYear calculated_fields.fetch(:AZ140_CCWS_LINE_3c)
                    xml.SubTotalContributions calculated_fields.fetch(:AZ140_CCWS_LINE_4c)
                    xml.TotalContributions calculated_fields.fetch(:AZ140_CCWS_LINE_5c)
                    xml.SubTotal calculated_fields.fetch(:AZ140_CCWS_LINE_6c)
                    xml.TotalIncStdDeduction calculated_fields.fetch(:AZ140_CCWS_LINE_7c)
                  end
                end
                xml.AZTaxableInc calculated_fields.fetch(:AZ140_LINE_45)
                xml.ComputedTax calculated_fields.fetch(:AZ140_LINE_46)
                xml.SubTotal calculated_fields.fetch(:AZ140_LINE_48)
                xml.DepTaxCredit calculated_fields.fetch(:AZ140_LINE_49)
                xml.FamilyIncomeTaxCredit calculated_fields.fetch(:AZ140_LINE_50)
                xml.BalanceOfTaxDue calculated_fields.fetch(:AZ140_LINE_52)
              end
              xml.TotalPaymentAndCredits do
                xml.AzIncTaxWithheld calculated_fields.fetch(:AZ140_LINE_53)
                xml.IncrExciseTaxCr calculated_fields.fetch(:AZ140_LINE_56)
              end
              xml.TotalPayments calculated_fields.fetch(:AZ140_LINE_59)
              xml.TaxDueOrOverpayment do
                if calculated_fields[:AZ140_LINE_60]
                  xml.TaxDue calculated_fields.fetch(:AZ140_LINE_60)
                else
                  xml.OverPaymentGrp do
                    xml.OverPaymentOfTax calculated_fields.fetch(:AZ140_LINE_61)
                    xml.OverPaymentApplied calculated_fields.fetch(:AZ140_LINE_62)
                    xml.OverPaymentBalance calculated_fields.fetch(:AZ140_LINE_63)
                  end
                end
              end
              if calculated_fields[:AZ140_LINE_79]
                xml.RefundAmt calculated_fields.fetch(:AZ140_LINE_79)
              else
                xml.AmtOwed calculated_fields.fetch(:AZ140_LINE_80)
              end
              xml.OtherExempInfo do
                xml.Name do
                  xml.FirstName "sdjfhdjs"
                  xml.MiddleInitial "M"
                  xml.LastName "fjsdhfjd"
                end
                if true # todo
                  xml.StillBorn do
                    xml.StillBornNbr 2
                    xml.StillBorn "X"
                  end
                elsif true # todo
                  xml.Over65 do
                    xml.SSN "123456789"
                    xml.CareFacility "X"
                  end
                end
              end #TODO fix after we figure out source of dependent information
            end

            xml_doc.at('*')
          end

          FILING_STATUS_OPTIONS = { :married_filing_jointly => 'MarriedJoint',
                                    :head_of_household => 'HeadHousehold',
                                    :married_filing_separately => 'MarriedFilingSeparateReturn',
                                    :single => "Single" }

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

          def schema_file
            File.join(Rails.root, "vendor", "us_states", "unpacked", "AZIndividual2023v1.0", "AZIndividual", "IndividualReturnAZ140.xsd")
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
            [
              {
                xml: nil, #SubmissionBuilder::Ty2022::States::Az::Documents::Az140,
                pdf: PdfFiller::Az140Pdf,
                include: true
              }
            ]
          end

          def calculated_fields
            @az140_fields ||= @submission.data_source.tax_calculator.calculate
          end
        end
      end
    end
  end
end