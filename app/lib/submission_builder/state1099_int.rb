module SubmissionBuilder
  class State1099Int < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def document
      form1099int = @kwargs[:form1099int]
      index = @kwargs[:index]
      intake = @kwargs[:intake]

      build_xml_doc("State1099Int", documentId: "State1099Int-#{index}") do |xml|
        if form1099int.payer.present? && form1099int.payer != ''
          xml.PayerName payerNameControl: form1099int.payer.gsub(/\s+|-/, '').upcase[0..3] do
            xml.BusinessNameLine1Txt sanitize_for_xml(form1099int.payer.tr('-', ' '), 75)
          end
        end
        xml.PayerEIN form1099int.payer_tin&.tr('-', '') if form1099int.payer_tin
        xml.RecipientSSN form1099int.recipient_tin&.tr('-', '') if form1099int.recipient_tin
        recipient = if form1099int.recipient_tin&.tr('-', '') == intake.primary.ssn
                      intake.primary
                    elsif form1099int.recipient_tin&.tr('-', '') == intake.spouse.ssn
                      intake.spouse
                    end
        xml.RecipientName sanitize_for_xml(recipient.full_name)
        xml.InterestIncome form1099int.amount_1099 if form1099int.amount_1099
        xml.InterestOnBondsAndTreasury form1099int.interest_on_government_bonds if form1099int.interest_on_government_bonds
        xml.FederalTaxWithheld form1099int.tax_withheld if form1099int.tax_withheld
        xml.TaxExemptInterest form1099int.tax_exempt_interest if form1099int.tax_exempt_interest
        xml.TaxExemptCUSIP form1099int.tax_exempt_and_tax_credit_bond_cusip_number if form1099int.tax_exempt_and_tax_credit_bond_cusip_number
      end
    end
  end
end
