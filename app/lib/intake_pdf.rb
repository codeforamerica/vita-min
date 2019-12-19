class IntakePdf
  SOURCE_PDF = "app/lib/pdfs/f13614c.pdf"

  def initialize(intake)
    @intake = intake
  end

  def hash_for_pdf
    {
      has_wages: yes_no_unfilled_to_checkbox(@intake.has_wages)
    }
  end

  def output_file
    pdf_tempfile = Tempfile.new(
      ["f13614c", ".pdf"],
      "tmp/",
    )
    PdfForms.new.fill_form(SOURCE_PDF, pdf_tempfile.path, hash_for_pdf)
    pdf_tempfile
  end

  def yes_no_unfilled_to_checkbox(value)
    value == "yes" ? "Yes" : nil
  end
end