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
            document = build_xml_doc('efile:ReturnState', stateSchemaVersion: "AZIndividual2022v1.1")
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
              xml.LNPriorYrs @submission.data_source&.prior_last_names
              xml.FilingStatus filing_status
              xml.Exemptions do
                # todo: what about the other exemptions?
                xml.AgeExemp 1
                xml.VisionExemp 1
                xml.DependentsUnder17 1
                xml.Dependents17AndOlder 1
                xml.QualifyingParentsAncestors 1
              end # TODO fix after we figure out dependent information
              # TODO fix after we figure out dependent information
              xml.SupplementPageAttached 'X' # TODO fix after we figure out source of dependent information
              xml.Dependents do
                xml.DependentDetails do
                  xml.Name do
                    xml.FirstName "sdjfhdjs"
                    xml.MiddleInitial "M"
                    xml.LastName "fjsdhfjd"
                  end
                  xml.DependentSSN "123456789"
                  xml.RelationShip "son"
                  xml.NumMonthsLived 4
                  xml.DepUnder17 'X'
                end
              end
              xml.Additions do
                xml.FedAdjGrossIncome calculated_fields.fetch(:AMT_12)
                xml.ModFedAdjGrossInc calculated_fields.fetch(:AMT_14)
              end
              xml.AzAdjSubtotal calculated_fields.fetch(:AMT_19)
              xml.Subtractions do
                xml.USSSRailRoadBnft calculated_fields.fetch(:AMT_30)
              end
              xml.TotalSubtractions calculated_fields.fetch(:AMT_35)
              xml.Subtotal calculated_fields.fetch(:AMT_37)
              xml.AzSubtrAmts do
                xml.ExemAmtAge65OrOver calculated_fields.fetch(:AMT_38)
                xml.ExemAmtBlind calculated_fields.fetch(:AMT_39)
                xml.ExemAmtParentsAncestors calculated_fields.fetch(:AMT_41)
              end
              xml.AZAdjGrossIncome calculated_fields.fetch(:AMT_42)
              xml.DeductionAmt do
                xml.DeductionTypeIndc 'Standard' # todo: we only support standard tho 43S
                xml.AZDeductions calculated_fields.fetch(:AMT_43)

                xml.ClaimCharitableDed do
                  #calculated_fields.fetch(:AMT_44)
                  xml.CharitableDeduction "X"
                  xml.IncStdCharitableDed 2
                  xml.IncreaseStdDed do
                    xml.GiftByCashOrCheck calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_1c)
                    xml.OtherThanCashOrCheck calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_2c)
                    xml.CarrPriorYear calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_3c)
                    xml.SubTotalContributions calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_4c)
                    xml.TotalContributions calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_5c)
                    xml.SubTotal calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_6c)
                    xml.TotalIncStdDeduction calculated_fields.fetch(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_7c)
                  end
                end
                xml.AZTaxableInc calculated_fields.fetch(:AMT_45)
                xml.ComputedTax calculated_fields.fetch(:AMT_46)
                xml.SubTotal calculated_fields.fetch(:AMT_48)
                xml.DepTaxCredit calculated_fields.fetch(:AMT_49)
                xml.FamilyIncomeTaxCredit calculated_fields.fetch(:AMT_50)
                xml.BalanceOfTaxDue calculated_fields.fetch(:AMT_52)
              end
              xml.TotalPaymentAndCredits do
                xml.AzIncTaxWithheld calculated_fields.fetch(:AMT_53)
                xml.IncrExciseTaxCr calculated_fields.fetch(:AMT_56)
              end
              xml.TotalPayments calculated_fields.fetch(:AMT_59)
              xml.TaxDueOrOverpayment do
                if calculated_fields[:AMT_60]
                  xml.TaxDue calculated_fields.fetch(:AMT_60)
                else
                  xml.OverPaymentGrp do
                    xml.OverPaymentOfTax calculated_fields.fetch(:AMT_61)
                    xml.OverPaymentApplied calculated_fields.fetch(:AMT_62)
                    xml.OverPaymentBalance calculated_fields.fetch(:AMT_63)
                  end
                end
              end
              if calculated_fields[:AMT_79]
                xml.RefundAmt calculated_fields.fetch(:AMT_79)
              else
                xml.AmtOwed calculated_fields.fetch(:AMT_80)
              end
              xml.OtherExempInfo do
                xml.Name do
                  xml.FirstName "sdjfhdjs"
                  xml.MiddleInitial "M"
                  xml.LastName "fjsdhfjd"
                end
                xml.Over65

              end # TODO fix after we figure out source of dependent information

              xml.QualParentsAncestors 1 # TODO fix after we figure out source of dependent information
              xml.TotalPaymentAndCreditsType calculated_fields.fetch(:AMT_53)
              xml.IncrExciseTaxCr calculated_fields.fetch(:AMT_56)

              # do we have to put spouse in here
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
            File.join(Rails.root, "vendor", "us_states", "unpacked", "AZIndividual2022v1.1", "AZIndividual", "IndividualReturnAZ140.xsd")
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
                xml: nil, #SubmissionBuilder::Ty2022::States::Az::Documents::Az140,
                pdf: PdfFiller::Az140Pdf,
                include: true
              }
            ]
            supported_docs
          end

          def calculated_fields
            @az140_fields ||= @submission.data_source.tax_calculator.calculate
          end
        end
      end
    end
  end
end