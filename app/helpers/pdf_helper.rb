require 'prawn'
require 'interleave2of5'

module PdfHelper
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
    pdftk_wrapper = PdfForms.new
    pdftk_wrapper.fill_form(source_pdf_path, pdf_tempfile.path, hash_for_pdf)

    if respond_to? :nys_form_type
      num_pages = PDF::Reader.new(pdf_tempfile.path).page_count
      barcode_page_paths = (1..num_pages).map do |page_num|
        barcode_page_tempfile = Tempfile.new
        barcode = nys_10digit_barcode(nys_form_type, page_num)
        pdf = Prawn::Document.new
        pdf.rectangle([-5, 30], 155, 35)  # draw a white rectangle over the default barcode
        pdf.fill_color "ffffff"
        pdf.fill
        pdf.fill_color "000000"
        barcode.to_pdf(pdf, width: 3.0 / 2 * 0.8, x: 0, y: 0, height: 72 / 4, bottom_margin: 0)
        barcode_page_path = "/tmp/pg#{page_num}.pdf"
        pdf.render_file(barcode_page_path)
        barcode_page_path
      end
      puts(barcode_page_paths.count)
      pdftk_wrapper.cat(*barcode_page_paths, "/tmp/barcodes.pdf")

      new_pdf_tempfile = Tempfile.new(
        [source_pdf_name, "_with_replaced_barcodes.pdf"],
        "tmp/",
        )
      pdftk_wrapper.multistamp(pdf_tempfile.path, "/tmp/barcodes.pdf", new_pdf_tempfile.path)
      puts("hi")
      new_pdf_tempfile
    else
      pdf_tempfile
    end
  end

  def nys_10digit_barcode(form_type, page_num)
    three_digit_page_num = "%03d" % page_num
    tax_year = "23"
    vendor_source_code = "1963"
    s = "#{form_type}#{three_digit_page_num}#{tax_year}#{vendor_source_code}"
    barcode = Interleave2of5.new(s)
    barcode.encode # this method call is required to compute some important internal state
  end

  def pdf_mask(string, unmasked_char_count = 0)
    return string unless string.present?

    string.gsub(/.(?=.{#{unmasked_char_count}})/, 'X')
  end
end
