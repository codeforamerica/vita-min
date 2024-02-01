module PdfFiller
  class Ny201VPdf
    include PdfHelper

    def source_pdf_name
      "it201v_1223"
    end

    def tax_year
      MultiTenantService.statefile.current_tax_year
    end

    def hash_for_pdf
      {}
    end
  end
end