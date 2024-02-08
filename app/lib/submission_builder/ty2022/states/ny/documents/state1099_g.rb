module SubmissionBuilder
  module Ty2022
    module States
      module Ny
        module Documents
          class State1099G < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              form1099g = @kwargs[:form1099g]

              build_xml_doc("State1099G", documentId: "State1099G-#{form1099g.id}") do |xml|
                if form1099g.payer_name && form1099g.payer_name != ''
                  xml.PayerName payerNameControl: form1099g.payer_name.gsub(/\s+/, '').upcase[0..3] do
                    xml.BusinessNameLine1Txt form1099g.payer_name
                  end
                  xml.PayerUSAddress do
                    xml.AddressLine1Txt form1099g.payer_street_address if form1099g.payer_street_address.present?
                    xml.CityNm form1099g.payer_city if form1099g.payer_city.present?
                    xml.StateAbbreviationCd "NY"
                    xml.ZIPCd form1099g.payer_zip if form1099g.payer_zip.present?
                  end
                  xml.PayerEIN form1099g.payer_tin if form1099g.payer_tin.present?
                end
                recipient = if form1099g.recipient_primary?
                  form1099g.intake.primary
                elsif form1099g.recipient_spouse?
                  form1099g.intake.spouse
                end
                xml.RecipientSSN recipient.ssn if recipient.ssn.present?
                xml.RecipientName recipient.full_name if recipient.full_name.present?
                xml.RecipientUSAddress do
                  xml.AddressLine1Txt form1099g.recipient_address_line1 if form1099g.recipient_address_line1.present?
                  xml.AddressLine2Txt form1099g.recipient_address_line2 if form1099g.recipient_address_line2.present?
                  xml.CityNm form1099g.recipient_city if form1099g.recipient_city.present?
                  xml.StateAbbreviationCd "NY"
                  xml.ZIPCd form1099g.recipient_zip if form1099g.recipient_zip.present?
                end
                xml.UnemploymentCompensation form1099g.unemployment_compensation if form1099g.unemployment_compensation.present?
                xml.FederalTaxWithheld form1099g.federal_income_tax_withheld if form1099g.federal_income_tax_withheld.present?
                xml.State1099GStateLocalTaxGrp do
                  xml.StateTaxWithheldAmt form1099g.state_income_tax_withheld if form1099g.state_income_tax_withheld.present?
                  xml.StateAbbreviationCd "NY"
                  if form1099g.state_identification_number && form1099g.state_identification_number != ''
                    xml.PayerStateIdNumber form1099g.state_identification_number
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
