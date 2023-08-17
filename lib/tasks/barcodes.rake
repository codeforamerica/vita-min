require 'pdf/core'
require 'prawn'
require 'interleave2of5'

namespace :barcodes do
  desc "Play with barcodes"

  task generate_nys_style: :environment do |_task|
    barcode = Interleave2of5.new("201004220094")
    barcode.encode # this method call is required to compute some important internal state
    pdf = Prawn::Document.new
    barcode.to_pdf(pdf)
    pdf.render_file('/tmp/output.pdf')
    # combine it with it201 now

  end
end
