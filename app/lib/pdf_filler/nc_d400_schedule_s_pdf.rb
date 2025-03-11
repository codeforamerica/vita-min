module PdfFiller
  class NcD400ScheduleSPdf
    include PdfHelper

    def source_pdf_name
      "ncD400-Schedule-S-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nc)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        y_d400schswf_ssn: @submission.data_source.primary.ssn,
        y_d400wf_lname2_PG2: @submission.data_source.primary.last_name_and_suffix,
        y_d400schswf_li18_good: @xml_document.at('DedFedAGI USInterestInc')&.text || '0',
        y_d400schswf_li19_good: @xml_document.at('DedFedAGI TaxPortSSRRB')&.text || '0',
        y_d400schswf_li20_good: @xml_document.at('DedFedAGI BaileyRetireBenef')&.text || '0',
        y_d400schswf_li21_good: @xml_document.at('DedFedAGI CertRetireBeneByMember')&.text || '0',
        y_d400schswf_li27_good:  @xml_document.at('DedFedAGI ExmptIncFedRecInd')&.text || '0',
        y_d400schswf_li41_good:  @xml_document.at('DedFedAGI TotDedFromFAGI')&.text || '0',
      }
    end
  end
end
