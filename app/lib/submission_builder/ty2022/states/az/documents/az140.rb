module SubmissionBuilder::Ty2022::States::Az::Documents
  class Az140 < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods


    def document
      build_xml_doc("Form140") do |xml|
        xml.LNPriorYrs claimed: @submission.data_source&.prior_last_names
        xml.FilingStatus claimed: @submission.data_source.filing_status
        xml.Exemptions claimed: 1 # TODO fix after we figure out dependent information
        xml.QualifyingParentsAncestors claimed: 1 # TODO fix after we figure out dependent information
        xml.SupplementPageAttached claimed: 1 # TODO fix after we figure out source of dependent information
        xml.Dependents claimed: 1
        xml.AzAdjSubtotal claimed: calculated_fields.fetch(:AMT_19)
        xml.TotalSubtractions claimed: calculated_fields.fetch(:AMT_35)
        xml.Subtotal calculated_fields.fetch(:AMT_37)
        xml.AzSubtrAmts do
          xml.LineNumber38 claimed: calculated_fields.fetch(:AMT_38)
          xml.LineNumber39 claimed: calculated_fields.fetch(:AMT_39)
        end
        xml.AZAdjGrossIncome claimed: calculated_fields.fetch(:AMT_42)
        xml.TotalPayments claimed: calculated_fields.fetch(:AMT_59)
        xml.TaxDueOrOverpayment do
          xml.LineNumber60 claimed: calculated_fields.fetch(:AMT_60)
          xml.LineNumber61 claimed: calculated_fields.fetch(:AMT_61)
          xml.LineNumber63 claimed: calculated_fields.fetch(:AMT_63)
        end
        xml.RefundAmt claimed: calculated_fields.fetch(:AMT_79)
        xml.AmtOwed claimed: calculated_fields.fetch(:AMT_80)
        xml.OtherExempInfo claimed: 1 # TODO fix after we figure out source of dependent information
        xml.DependentDetails claimed: 1 # TODO fix after we figure out source of dependent information
        xml.QualParentsAncestors claimed: 1 # TODO fix after we figure out source of dependent information
        xml.FedAdjGrossIncome claimed: calculated_fields.fetch(:AMT_12)
        xml.ModFedAdjGrossInc claimed: calculated_fields.fetch(:AMT_14)
        xml.USSSRailRoadBnft claimed: calculated_fields.fetch(:AMT_30)
        xml.ExemAmtParentsAncestors claimed: calculated_fields.fetch(:AMT_41)
        xml.AZDeductions claimed: calculated_fields.fetch(:AMT_43)
        xml.ClaimCharitableDed claimed: calculated_fields.fetch(:AMT_44)
        xml.AZTaxableInc claimed: calculated_fields.fetch(:AMT_45)
        xml.ComputedTax claimed: calculated_fields.fetch(:AMT_46)
        xml.SubTotal claimed: calculated_fields.fetch(:AMT_48)
        xml.DepTaxCredit claimed: calculated_fields.fetch(:AMT_49)
        xml.FamilyIncomeTaxCredit claimed: calculated_fields.fetch(:AMT_50)
        xml.BalanceOfTaxDue claimed: calculated_fields.fetch(:AMT_52)
        xml.TotalPaymentAndCreditsType claimed: calculated_fields.fetch(:AMT_53)
        xml.IncrExciseTaxCr claimed: calculated_fields.fetch(:AMT_56)
      end
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end

