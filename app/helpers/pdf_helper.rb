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

  def bool_checkbox(value)
    value ? "Yes" : nil
  end

  def check_if_both_are_no(value_a, value_b)
    value_a == "no" && value_b == "no" ? "Yes" : nil
  end

  def strftime_date(date)
    if date.present?
      date.strftime("%-m/%-d/%Y")
    end
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