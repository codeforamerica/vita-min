module PdfFiller
  class Ny201VPdf
    include PdfHelper

    def source_pdf_name
      "it201v_1223"
    end

    def nys_form_type
      "040"
    end

    def tax_year
      2023
    end

    def barcode_overlay_rect
      [[0, 64], 125, 67]
    end

    def hash_for_pdf
      {}
    end

  end
end