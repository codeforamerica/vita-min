# frozen_string_literal: true

module SubmissionBuilder
  module Ty2022
    module States
      module Az
        class AzReturnXml < SubmissionBuilder::StateReturn
          include DependentRelationshipTable

          FILING_STATUS_OPTIONS = {
            married_filing_jointly: 'MarriedJoint',
            head_of_household: 'HeadHousehold',
            married_filing_separately: 'MarriedFilingSeparateReturn',
            single: "Single"
          }.freeze

          STANDARD_DEDUCTIONS = {
            single: 12950,
            married_filing_jointly: 25900,
            married_filing_separately: 12950,
            head_of_household: 19400,
          }.freeze

          private

          def attached_documents_parent_tag
            'ReturnDataState'
          end

          def build_xml_doc_tag
            'efile:ReturnState'
          end

          def state_schema_version
            "AZIndividual2024v2.0"
          end

          def build_state_specific_tags(document)
            document.at("ReturnHeaderState ReturnType").add_next_sibling(special_program)
            if !@submission.data_source.routing_number.nil? && !@submission.data_source.account_number.nil?
              document.at("ReturnState").add_child(financial_transaction)
            end
          end

          def documents_wrapper
            xml_doc = build_xml_doc("Form140") do |xml|
              xml.LNPriorYrs sanitize_for_xml(@submission.data_source.prior_last_names)
              xml.FilingStatus filing_status
              if hoh_qualifying_person.present? && @submission.data_source.filing_status_hoh?
                xml.QualChildDependentName do
                  xml.FirstName sanitize_for_xml(hoh_qualifying_person[:first_name], 16)
                  xml.LastName sanitize_for_xml(hoh_qualifying_person[:last_name], 32)
                end
              end
              xml.Exemptions do
                xml.AgeExemp calculated_fields.fetch(:AZ140_LINE_8)
                xml.VisionExemp calculated_fields.fetch(:AZ140_LINE_9)
                xml.DependentsUnder17 calculated_fields.fetch(:AZ140_LINE_10A)
                xml.Dependents17AndOlder calculated_fields.fetch(:AZ140_LINE_10B)
                xml.QualifyingParentsAncestors calculated_fields.fetch(:AZ140_LINE_11A)
              end # TODO fix after we figure out dependent information
              xml.SupplementPageAttached 'X' # TODO Check box if theres not enough space on the first page for dependents
              xml.Dependents do
                @submission.data_source.dependents.reject(&:is_qualifying_parent_or_grandparent?).each do |dependent|
                  xml.DependentDetails do
                    xml.Name do
                      xml.FirstName sanitize_for_xml(dependent.first_name, 16)
                      xml.MiddleInitial sanitize_middle_initial(dependent.middle_initial) if sanitize_middle_initial(dependent.middle_initial).present?
                      xml.LastName sanitize_for_xml(dependent.last_name, 32)
                    end
                    unless dependent.ssn.nil?
                      xml.DependentSSN dependent.ssn.delete('-')
                    end
                    xml.RelationShip relationship_key(dependent.relationship)
                    xml.NumMonthsLived dependent.months_in_home
                    if dependent.under_17?
                      xml.DepUnder17 'X'
                    else
                      xml.Dep17AndOlder 'X'
                    end
                  end
                end
                @submission.data_source.dependents.select(&:is_qualifying_parent_or_grandparent?).each do |dependent|
                  xml.QualParentsAncestors do
                    xml.Name do
                      xml.FirstName sanitize_for_xml(dependent.first_name, 16)
                      xml.MiddleInitial sanitize_middle_initial(dependent.middle_initial) if sanitize_middle_initial(dependent.middle_initial).present?
                      xml.LastName sanitize_for_xml(dependent.last_name, 32)
                    end
                    unless dependent.ssn.nil?
                      xml.DependentSSN dependent.ssn.delete('-')
                    end
                    xml.RelationShip relationship_key(dependent.relationship)
                    xml.NumMonthsLived dependent.months_in_home
                    xml.IsOverSixtyFive 'X' # all dependents in this section are over 65
                    if dependent.passed_away_yes?
                      xml.DiedInTaxYear 'X'
                    end
                  end
                end
              end
              xml.Additions do
                xml.FedAdjGrossIncome calculated_fields.fetch(:AZ140_LINE_12)
                xml.ModFedAdjGrossInc calculated_fields.fetch(:AZ140_LINE_14)
              end
              xml.AzAdjSubtotal calculated_fields.fetch(:AZ140_LINE_19)
              xml.Subtractions do
                add_non_zero_value(xml, :IntUSObligations, :AZ140_LINE_28)
                xml.ExecFedStateLocGovPen calculated_fields.fetch(:AZ140_LINE_29A)
                xml.SubExclBenAnnPen calculated_fields.fetch(:AZ140_LINE_29B)
                xml.USSSRailRoadBnft calculated_fields.fetch(:AZ140_LINE_30)
                xml.WageAmIndian calculated_fields.fetch(:AZ140_LINE_31)
                xml.CompNtnlGrdArmdFrcs calculated_fields.fetch(:AZ140_LINE_32)
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
                xml.DeductionTypeIndc calculated_fields.fetch(:AZ140_LINE_43S)
                xml.AZDeductions calculated_fields.fetch(:AZ140_LINE_43)
                if calculated_fields[:AZ140_LINE_44C]
                  xml.ClaimCharitableDed do
                    xml.CharitableDeduction calculated_fields.fetch(:AZ140_LINE_44C)
                    xml.IncStdCharitableDed calculated_fields.fetch(:AZ140_LINE_44)
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
                end
                xml.AZTaxableInc calculated_fields.fetch(:AZ140_LINE_45)
                xml.ComputedTax calculated_fields.fetch(:AZ140_LINE_46)
                xml.SubTotal calculated_fields.fetch(:AZ140_LINE_48)
                xml.DepTaxCredit calculated_fields.fetch(:AZ140_LINE_49)
                xml.FamilyIncomeTaxCredit calculated_fields.fetch(:AZ140_LINE_50)
                xml.CreditsFromAZ301 calculated_fields.fetch(:AZ140_LINE_51)
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
              if calculated_fields[:AZ140_LINE_79].positive?
                xml.RefundAmt calculated_fields.fetch(:AZ140_LINE_79)
              else
                xml.AmtOwed calculated_fields.fetch(:AZ140_LINE_80)
              end
            end
            xml_doc.at('*')
          end

          def filing_status
            FILING_STATUS_OPTIONS[@submission.data_source.filing_status]
          end

          def financial_transaction
            FinancialTransaction.build(
              @submission,
              validate: false,
              kwargs: { refund_amount: calculated_fields.fetch(:AZ140_LINE_79) }
            ).document.at("*")
          end

          def schema_file
            SchemaFileLoader.load_file("us_states", "unpacked", "AZIndividual2024v2.0", "AZIndividual", "IndividualReturnAZ140.xsd")
          end

          def special_program
            "<SpecialProgram>Direct File</SpecialProgram>"
          end

          def supported_documents
            supported_docs = [
              {
                xml: nil,
                pdf: PdfFiller::Az140Pdf,
                include: true
              },
              {
                xml: nil,
                pdf: PdfFiller::Az8879Pdf,
                include: true
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Az::Documents::Az301,
                pdf: PdfFiller::Az301Pdf,
                include: @submission.data_source.az321_contributions.present? || @submission.data_source.az322_contributions.present?
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Az::Documents::Az321Contribution,
                pdf: PdfFiller::Az321Pdf,
                include: @submission.data_source.az321_contributions.present?,
              },
              {
                xml: SubmissionBuilder::Ty2022::States::Az::Documents::Az322,
                pdf: PdfFiller::Az322Pdf,
                include: @submission.data_source.az322_contributions.present?
              }
            ]

            supported_docs += combined_w2s
            supported_docs += form1099rs
            supported_docs += form1099gs
            supported_docs += form1099ints
            supported_docs
          end

          def calculated_fields
            @az140_fields ||= @submission.data_source.tax_calculator.calculate
          end

          def hoh_qualifying_person
            @hoh_qualifying_person ||= xml_hoh_qualifying_person || json_hoh_qualifying_person
          end

          def xml_hoh_qualifying_person
            xml_hoh = @submission.data_source.direct_file_data.hoh_qualifying_person_name&.split(/ /, 2)

            if xml_hoh.present?
              {
                first_name: xml_hoh[0],
                last_name: xml_hoh[1]
              }
            end
          end

          def json_hoh_qualifying_person
            json_hoh = @intake.direct_file_json_data.dependents.find(&:hoh_qualifying_person)

            if json_hoh.present?
              {
                first_name: json_hoh.first_name,
                last_name: json_hoh.last_name
              }
            end
          end
        end
      end
    end
  end
end
