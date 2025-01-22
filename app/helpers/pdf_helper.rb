module PdfHelper
  def formatted_date(date_str, format)
    return if date_str.nil?

    Date.parse(date_str)&.strftime(format)
  end

  def yes_no_unfilled_to_checkbox(value)
    value == "yes" ? "1" : nil
  end

  def yes_no_unfilled_to_opposite_checkbox(value)
    value == "no" ? "1" : nil
  end

  def bool_checkbox(value)
    value ? "1" : nil
  end

  def xml_value_to_bool(node, type)
    if type == 'CheckboxType'
      node&.text == "X"
    elsif type == 'BooleanType'
      return nil if node.nil?

      %w[true 1].include?(node.text)
    else
      raise StandardError, "Unknown type #{type}"
    end
  end

  def collective_yes_no_unsure(*values)
    return "unfilled" if values.all?("unfilled")
    return "yes" if values.any?("yes")
    return "unsure" if values.any?("unsure")

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
    PdfForms.new.fill_form(source_pdf_path, pdf_tempfile.path, hash_for_pdf, { need_appearances: true })
    pdf_tempfile
  end

  def pdf_mask(string, unmasked_char_count = 0)
    return string unless string.present?

    string.gsub(/.(?=.{#{unmasked_char_count}})/, 'X')
  end
end
