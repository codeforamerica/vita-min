module SubmissionBuilder
  class State1099R < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def document
      form1099r = @kwargs[:form1099r]
      state_abbreviation = form1099r.intake.state_code.upcase

      build_xml_doc("IRS1099R", documentId: "IRS1099R-#{form1099r.id}") do |xml|
        xml.PayerNameControlTxt form1099r.payer_name_control
        if form1099r.payer_name.present?
          xml.PayerName do
            xml.BusinessNameLine1Txt sanitize_for_xml(form1099r.payer_name.tr('-', ' '), 75)
          end
          xml.PayerUSAddress do
            xml.AddressLine1Txt sanitize_for_xml(form1099r.payer_address_line1, 35) if form1099r.payer_address_line1.present?
            xml.AddressLine2Txt sanitize_for_xml(form1099r.payer_address_line2, 35) if form1099r.payer_address_line2.present?
            xml.CityNm sanitize_for_xml(form1099r.payer_city_name, 22) if form1099r.payer_city_name.present?
            xml.StateAbbreviationCd form1099r.payer_state_code if form1099r.payer_state_code.present?
            xml.ZIPCd sanitize_zipcode(form1099r.payer_zip) if form1099r.payer_zip.present?
          end
          xml.PayerEIN form1099r.payer_identification_number
          xml.RecipientSSN sanitize_for_xml(form1099r.recipient_ssn) if form1099r.recipient_ssn.present?
          xml.RecipientNm sanitize_for_xml(form1099r.recipient_name) if form1099r.recipient_name.present?
          xml.GrossDistributionAmt form1099r.gross_distribution_amount&.round
          xml.TaxableAmt form1099r.taxable_amount&.round
          if form1099r.taxable_amount_not_determined?
            xml.TxblAmountNotDeterminedInd 'X'
          end
          if form1099r.total_distribution?
            xml.TotalDistributionInd 'X'
          end
          xml.FederalIncomeTaxWithheldAmt form1099r.federal_income_tax_withheld_amount&.round
          xml.F1099RDistributionCd form1099r.distribution_code if form1099r.distribution_code.present?
          xml.DesignatedROTHAcctFirstYr form1099r.designated_roth_account_first_year if form1099r.designated_roth_account_first_year.present?
          xml.F1099RStateLocalTaxGrp do
            xml.F1099RStateTaxGrp do
              xml.StateTaxWithheldAmt form1099r.state_tax_withheld_amount&.round
              xml.StateAbbreviationCd form1099r.state_code if form1099r.state_code.present?
              xml.PayerStateIdNum form1099r.payer_state_identification_number if form1099r.payer_state_identification_number.present?
              xml.StateDistributionAmt form1099r.state_distribution_amount&.round
            end
          end
          if form1099r.standard?
            xml.StandardOrNonStandardCd 'S'
          else
            xml.StandardOrNonStandardCd 'N'
          end
        end
      end
    end
  end
end
