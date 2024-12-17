module SubmissionBuilder
  module Ty2024
    module States
      module Md
        module Documents
          class Md1099G < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              form1099g = @kwargs[:form1099g]
              state_abbreviation = "MD"

              build_xml_doc("MD1099G", documentId: "MD1099G-#{form1099g.id}") do |xml|
                if form1099g.payer_name.present?
                  xml.Payer do
                    xml.Name do
                      xml.BusinessNameLine1Txt sanitize_for_xml(form1099g.payer_name.tr('-', ' '), 75)
                    end
                    xml.Address do
                      xml.AddressLine1Txt sanitize_for_xml(form1099g.payer_street_address.tr('-', ' '), 35)
                      xml.CityNm sanitize_for_xml(form1099g.payer_city, 22)
                      xml.StateAbbreviationCd state_abbreviation
                      xml.ZIPCd form1099g.payer_zip
                    end
                    xml.IDNumber form1099g.payer_tin
                  end
                end
                recipient = if form1099g.recipient_primary?
                              form1099g.intake.primary
                            elsif form1099g.recipient_spouse?
                              form1099g.intake.spouse
                            end
                xml.Recipient do
                  xml.SSN recipient.ssn
                  xml.Name sanitize_for_xml(recipient.full_name, 35)
                  xml.Address do
                    xml.USAddress do
                      xml.AddressLine1Txt sanitize_for_xml(form1099g.recipient_address_line1, 35)
                      xml.AddressLine2Txt sanitize_for_xml(form1099g.recipient_address_line2, 35) if form1099g.recipient_address_line2.present?
                      xml.CityNm sanitize_for_xml(form1099g.recipient_city, 22)
                      xml.StateAbbreviationCd state_abbreviation
                      xml.ZIPCd sanitize_for_xml(form1099g.recipient_zip)
                    end
                  end
                end
                xml.UnemploymentCompensationPaid form1099g.unemployment_compensation_amount&.round
                xml.FederalTaxWithheld form1099g.federal_income_tax_withheld_amount&.round
                xml.StateTaxWithheld form1099g.state_income_tax_withheld_amount&.round
              end
            end
          end
        end
      end
    end
  end
end
