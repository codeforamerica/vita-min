module PdfFiller
  class F15080VitaConsentToDisclosePdf
    include PdfHelper

    def source_pdf_name
      "f15080-TY2023"
    end

    def output_filename
      "F15080 - VITA Consent To Disclose.pdf"
    end

    def document_type
      DocumentTypes::Form15080
    end

    def initialize(intake)
      @intake = intake
    end

    def hash_for_pdf
      return {} unless @intake.primary_consented_to_service_at.present? #&& @intake.disclose_consented_at.present? #this right?

      # data = {
      #     primary_legal_name: @intake.primary.first_and_last_name,
      #     primary_consented_at: strftime_date(@intake.primary_consented_to_service_at),
      # }

      data = {
        "form1[0].page4[0].primaryTaxpayer[0]" => @intake.primary.first_and_last_name,
        "form1[0].page4[0].primarydateSigned[0]" => strftime_date(@intake.primary_consented_to_service_at),
      }
      if @intake.spouse_consented_to_service_at.present?
        data.merge!(
          "form1[0].page4[0].secondaryTaxpayer[0]" => @intake.spouse.first_and_last_name,
          "form1[0].page4[0].secondaryDateSigned[0]" => strftime_date(@intake.spouse_consented_to_service_at),
        )
      end
      data
    end
  end
end
