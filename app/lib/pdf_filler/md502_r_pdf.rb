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
        'Your First Name': @submission.data_source.primary.first_name,
        'Primary MI': @submission.data_source.primary.middle_initial,
        'Your Last Name': @submission.data_source.primary.last_name_and_suffix,
        'Your Social Security Number': @submission.data_source.primary.ssn,
        'Spouses First Name': @submission.data_source.spouse.first_name,
        'Spouse MI': @submission.data_source.spouse.middle_initial,
        'Spouses Last Name': @submission.data_source.spouse.last_name_and_suffix,
        'Spouses Social Security Number': @xml_document.at('Secondary TaxpayerSSN')&.text,
        'Your Age 1': @xml_document.at('PrimaryAge')&.text,
        'Spouses Age': @xml_document.at('SecondaryAge')&.text,
        You: check_box_if_x(@xml_document.at('PriTotalPermDisabledIndicator')&.text),
        Spouse: check_box_if_x(@xml_document.at('SecTotalPermDisabledIndicator')&.text),
        'and Tier II See Instructions for Part 5                                   9a': @xml_document.at('PriSSecurityRailRoadBenefits')&.text,
        '9b': @xml_document.at('SecSSecurityRailRoadBenefits')&.text
        }
      if Flipper.enabled?(:show_retirement_ui)
        answers.merge!(
          'compensation plan or foreign retirement income                           1a' => @xml_document.at('SourceRetirementIncome PrimaryTaxpayer EmployeeRetirementSystem')&.text,
          '1b' => @xml_document.at('SourceRetirementIncome SecondaryTaxpayer EmployeeRetirementSystem')&.text,
          'including foreign retirement income                                     7a' => @xml_document.at('SourceRetirementIncome PrimaryTaxpayer OtherAndForeign')&.text,
          '7b' => @xml_document.at('SourceRetirementIncome SecondaryTaxpayer OtherAndForeign')&.text,
          'income on lines 1z 4b and 5b of your federal Form 1040 and line 8t of your federal Schedule 1      8' => @xml_document.at('SourceRetirementIncome TotalPensionsIRAsAnnuities')&.text,
          'retirement from code letter v on Form 502SU income subtracted on Maryland Form 502  10a' => @xml_document.at('PriMilLawEnforceIncSub')&.text,
          '10b' => @xml_document.at('SecMilLawEnforceIncSub')&.text,
          '11 Pension Exclusion from line 5 of Worksheet 13A                           11a 1' => @xml_document.at('PriPensionExclusion')&.text,
          '11b' => @xml_document.at('SecPensionExclusion')&.text,
        )
      end
      answers
    end

    def check_box_if_x(value)
      value == "X" ? 'On' : 'Off'
    end
  end
end
