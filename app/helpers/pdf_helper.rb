module PdfHelper
  def yes_no_unfilled_to_checkbox(value)
    value == "yes" ? "Yes" : nil
  end

  def yes_no_unfilled_to_radio(value)
    {
      "yes" => "Yes",
      "no" => "No",
    }[value]
  end

  def yes_no_unfilled_to_opposite_checkbox(value)
    value == "no" ? "Yes" : nil
  end

  def strftime_date(date)
    date.strftime("%-m/%-d/%Y")
  end

  def source_pdf_path
    "app/lib/pdfs/#{source_pdf_name}.pdf"
  end

  def output_file
    pdf_tempfile = Tempfile.new(
      [source_pdf_name, ".pdf"],
      "tmp/",
      )
    PdfForms.new.fill_form(source_pdf_path, pdf_tempfile.path, hash_for_pdf)
    pdf_tempfile
  end
end