module PdfFiller
  class Az322Pdf
    include PdfHelper

    def source_pdf_name
      "az322-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "TP_Name" => @submission.data_source.primary.full_name,
        "TP_SSN" => @submission.data_source.primary.ssn,
        "Spouse_Name" => @submission.data_source.spouse.full_name,
        "Spouse_SSN" => @submission.data_source.spouse.ssn,
        "4" => @xml_document.at('Form322 TotalContributionsContSheet')&.text,
        "5" => @xml_document.at('Form322 TotalContributions')&.text,
        "9" => '0',
        "10" => '0',
        "11" => @xml_document.at('Form322 SubTotalAmt')&.text,
        "12" => @xml_document.at('Form322 SingleHOH')&.text,
        "13" => @xml_document.at('Form322 CurrentYrCr')&.text,
        "20" => @xml_document.at('Form322 CurrentYrCr')&.text,
        "22" => @xml_document.at('Form322 TotalAvailCr')&.text,
        "4h" => @xml_document.at('Form322 TotalContributionsContSheet')&.text,
      }
      @submission.data_source.az322_contributions.each_with_index do |contribution, index|
        if index < 3 # First three contributions on the first page with labels 1-3
          prefix = (index + 1).to_s
        else
          letter = ('a'..'g').to_a[index - 3] # Remaining contributions on page 3 use labels #4a-4g
          prefix = "4#{letter}"
        end
        answers["#{prefix}a"] = contribution.date_of_contribution.strftime("%m%d")
        answers["#{prefix}b"] = contribution.ctds_code
        answers["#{prefix}c"] = contribution.school_name
        answers["#{prefix}d"] = contribution.district_name
        answers["#{prefix}e"] = contribution.amount.round
      end

      answers
    end
  end
end
