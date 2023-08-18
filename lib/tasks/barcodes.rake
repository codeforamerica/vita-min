require 'pdf/core'
require 'prawn'
require 'interleave2of5'

namespace :barcodes do
  desc "Play with barcodes"

  task generate_nys_style: :environment do |_task|
    # This code is just a proof of concept to validate that we can indeed place a 1D barcode on each page.
    # Please improve it before putting it into production, e.g. consider removing `system` and reimplementing
    # with PdftkWrapper, clean up tempfiles, use the Rails tempdir, use less predictable filenames, and evaluate pdftk
    # `multistamp` to possibly decrease the # of pdftk invocations.

    # This code does not place the *text* above the barcode, but we need to do that before NYS would be happy.
    # We've added text to a PDF before, so it seems like not a big deal.

    (1..4).each do |page_num| # for each page in the IT201 PDF, of which there happen to be 4
      # Generate a barcode
      barcode = Barcodes.nys_10digit(page_num)
      pdf = Prawn::Document.new
      barcode.to_pdf(pdf, width: 3.0 / 2 * 0.8, x: 0, y: 0, height: 72 / 4, bottom_margin: 0)
      pdf.render_file("/tmp/pg#{page_num}.pdf")

      # Extract the page
      system("./vendor/pdftk/pdftk", "A=app/lib/pdfs/it201_fill_in_without_1d_barcode.pdf", "cat", "A#{page_num}", "output", "/tmp/A#{page_num}.pdf")

      # Combine with barcode
      system("./vendor/pdftk/pdftk", "/tmp/A#{page_num}.pdf", "stamp", "/tmp/pg#{page_num}.pdf", "output", "/tmp/combined#{page_num}.pdf")
    end

    # combine all those
    system("./vendor/pdftk/pdftk", "A=/tmp/combined1.pdf", "B=/tmp/combined2.pdf", "C=/tmp/combined3.pdf", "D=/tmp/combined4.pdf", "cat", "A1", "B1", "C1", "D1", "output", "/tmp/it201-with-barcodes.pdf")
  end
end

module Barcodes
  def self.nys_10digit(page_num)
    form_type = "201"
    tax_year = "22"
    vendor_source_code = "1234"
    s = "#{form_type}#{page_num}#{tax_year}#{vendor_source_code}"
    barcode = Interleave2of5.new(s)
    barcode.encode # this method call is required to compute some important internal state
  end
end
