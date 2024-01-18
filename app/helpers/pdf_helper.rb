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
    PdfForms.new.fill_form(source_pdf_path, pdf_tempfile.path, hash_for_pdf)

    if respond_to? :nys_form_type
      ny_pdf_with_cfa_barcode(pdf_tempfile)
    else
      pdf_tempfile
    end
  end

  def ny_pdf_with_cfa_barcode(pdf_tempfile)
    num_pages = PDF::Reader.new(pdf_tempfile.path).page_count
    barcode_page_paths = (1..num_pages).map do |page_num|
      barcode_string = nys_12digit_barcode_value(nys_form_type, page_num)
      rect_params = barcode_overlay_rect
      pdf = Prawn::Document.new
      pdf.rectangle(*rect_params)  # draw a white rectangle over the default barcode
      pdf.fill_color "ffffff"
      pdf.fill
      pdf.fill_color "000000"
      pdf.text_box barcode_string, :at => [0, 26], :width => 117, :size => 8, :align => :center
      barcode = generate_barcode(barcode_string)
      barcode.to_pdf(pdf, width: 1.1, x: -20, y: 0, height: 18, bottom_margin: 0)
      barcode_page_tempfile = Tempfile.new(
        ["pg#{page_num}", ".pdf"],
        "tmp/",
        )
      pdf.render_file(barcode_page_tempfile.path)
      barcode_page_tempfile
    end
    pdftk_wrapper = PdfForms.new
    barcode_pages_tempfile = Tempfile.new(
      ["barcodes", ".pdf"],
      "tmp/",
      )
    pdftk_wrapper.cat(*barcode_page_paths.map(&:path), barcode_pages_tempfile.path)

    new_pdf_tempfile = Tempfile.new(
      [source_pdf_name, "_with_replaced_barcodes.pdf"],
      "tmp/",
      )
    pdftk_wrapper.multistamp(pdf_tempfile.path, barcode_pages_tempfile.path, new_pdf_tempfile.path)
    new_pdf_tempfile
  end

  def nys_10digit_barcode_value(form_type, page_num)
    vendor_source_code = Rails.configuration.nactp_vendor_code
    last_two_digits_of_tax_year = tax_year.to_s[-2..-1]
    "#{form_type}#{page_num}#{last_two_digits_of_tax_year}#{vendor_source_code}"
  end

  def nys_12digit_barcode_value(form_type, page_num)
    three_digit_page_num = "%03d" % page_num
    vendor_source_code = Rails.configuration.nactp_vendor_code
    last_two_digits_of_tax_year = tax_year.to_s[-2..-1]
    "#{form_type}#{three_digit_page_num}#{last_two_digits_of_tax_year}#{vendor_source_code}"
  end

  def generate_barcode(s)
    barcode = Interleave2of5.new(s)
    barcode.encode # this method call is required to compute some important internal state
  end

  def pdf_mask(string, unmasked_char_count = 0)
    return string unless string.present?

    string.gsub(/.(?=.{#{unmasked_char_count}})/, 'X')
  end
end
