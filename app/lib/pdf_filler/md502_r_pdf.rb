module PdfFiller
  class Md502RPdf
    include PdfHelper

    def source_pdf_name
      "md502R-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        'Your First Name': @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'Primary MI': @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        'Your Last Name': @xml_document.at('Primary TaxpayerName LastName')&.text,
        'Your Social Security Number': @xml_document.at('Primary TaxpayerSSN')&.text,
        'Spouses First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Spouse MI': @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text,
        'Spouses Last Name': @xml_document.at('Secondary TaxpayerName LastName')&.text,
        'Spouses Social Security Number': @xml_document.at('Secondary TaxpayerSSN')&.text,
        'Your Age 1': @xml_document.at('PrimaryAge')&.text,
        'Spouses Age': @xml_document.at('SecondaryAge')&.text,
        You: check_box_if_x(@xml_document.at('PriTotalPermDisabledIndicator')&.text),
        Spouse: check_box_if_x(@xml_document.at('SecTotalPermDisabledIndicator')&.text),
        }
      if Flipper.enabled?(:show_md_ssa)
        answers.merge!(
          "and Tier II See Instructions for Part 5                                   9a" => @xml_document.at('PriSSecurityRailRoadBenefits')&.text,
          "9b" => @xml_document.at('SecSSecurityRailRoadBenefits')&.text
        )
      end
      if Flipper.enabled?(:show_retirement_ui)
        answers.merge!(
          'compensation plan or foreign retirement income                           1a' => @xml_document.at('SourceRetirementIncome PrimaryTaxPayer EmployeeRetirementSystem')&.text,
          '1b' => @xml_document.at('SourceRetirementIncome SecondaryTaxPayer EmployeeRetirementSystem')&.text,
          'including foreign retirement income                                     7a' => @xml_document.at('SourceRetirementIncome PrimaryTaxPayer OtherAndForeign')&.text,
          '7b' => @xml_document.at('SourceRetirementIncome SecondaryTaxPayer OtherAndForeign')&.text,
          'income on lines 1z 4b and 5b of your federal Form 1040 and line 8t of your federal Schedule 1      8' => @xml_document.at('SourceRetirementIncome TotalPensionsIRAsAnnuities')&.text,
          'retirement from code letter v on Form 502SU income subtracted on Maryland Form 502  10a' => @xml_document.at('PriMilLawEnforceIncSub')&.text,
          '10b' => @xml_document.at('SecMilLawEnforceIncSub')&.text,
        )
      end
      answers
    end

    def check_box_if_x(value)
      value == "X" ? 'On' : 'Off'
    end
  end
end
