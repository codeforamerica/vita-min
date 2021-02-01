module PdfHelper

  def yes_no_unfilled_to_checkbox(value)
    value == "yes" ? "Yes" : nil
  end

  # Oddly, 0 is checked and 1 is unchecked in the 2020 f13614-c.
  def yes_no_unfilled_to_checkbox_0(value)
    value == "yes" ? 0 : nil
  end

  # Oddly, 0 is checked value in the 2020 f13614-c.
  def yes_no_unfilled_to_opposite_checkbox_0(value)
    value == "no" ? 0 : nil
  end

  def bool_checkbox(value)
    value ? "Yes" : nil
  end

  # Oddly, 0 is checked value in the 2020 f13614-c.
  def bool_checkbox_0(value)
    value ? 0 : nil
  end

  def collective_yes_no_unfilled(*values)
    return "yes" if values.any?("yes")
    return "unfilled" if values.all?("unfilled")

    "no"
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