class SubmissionBuilder::Ty2022::States::Az::Documents::Az321Contribution < SubmissionBuilder::Document
  include SubmissionBuilder::FormattingMethods

  def document
    az321contributions = @submission.data_source.az321_contributions
    @calculated_fields ||= @submission.data_source.tax_calculator.calculate

    build_xml_doc("Form321") do |xml|
      az321contributions&.first(3)&.each do |contribution|
        xml.CharityInfo do
          xml.QualCharityContrDate contribution.date_of_contribution
          xml.QualCharityCode contribution.charity_code
          xml.QualCharity contribution.charity_name
          xml.QualCharityAmt contribution.amount.round
        end
      end

      xml.TotalCharityAmtContSheet @calculated_fields.fetch(:AZ321_LINE_4)
      xml.TotalCharityAmt @calculated_fields.fetch(:AZ321_LINE_5)
      xml.AddCurYrCrAmtTotCshCont @calculated_fields.fetch(:AZ321_LINE_11)
      xml.TxPyrsStatus @calculated_fields.fetch(:AZ321_LINE_12)
      xml.TotCshContrFostrChrty @calculated_fields.fetch(:AZ321_LINE_13)
      xml.CurrentYrCr @calculated_fields.fetch(:AZ321_LINE_20)
      xml.TotalAvailCr @calculated_fields.fetch(:AZ321_LINE_22)

      if az321contributions.present? && az321contributions.size >= 4
        xml.ContinuationPages do

          az321contributions[3...10].each do |contribution|
            xml.CharityInfo do
              xml.QualCharityContrDate contribution.date_of_contribution
              xml.QualCharityCode contribution.charity_code
              xml.QualCharity contribution.charity_name
              xml.QualCharityAmt contribution.amount.round
            end
          end

          xml.ContTotalCharityAmt @calculated_fields.fetch(:AZ321_LINE_4H)
          xml.ContTotalCharityAmtAfter 0
        end
      end

    end
  end
end