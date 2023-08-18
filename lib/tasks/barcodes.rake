require 'pdf/core'
require 'prawn'
require 'interleave2of5'

namespace :barcodes do
  desc "Play with barcodes"

  task generate_nys_style: :environment do |_task|
    barcode = Barcodes.nys_10digit
    pdf = Prawn::Document.new
    barcode.to_pdf(pdf, width: 3.0 / 2 * 0.8, x: 0, y: 0, height: 72 / 4, bottom_margin: 0)
    pdf.render_file('/tmp/output.pdf')
  end
end

module Barcodes
  def self.nys_10digit
    form_type = "201"
    page_num = "1"
    tax_year = "22"
    vendor_source_code = "1234"
    s = "#{form_type}#{page_num}#{tax_year}#{vendor_source_code}"
    barcode = Interleave2of5.new(s)
    barcode.encode # this method call is required to compute some important internal state
  end
end
