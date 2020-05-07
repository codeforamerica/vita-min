require "mini_magick"

class BankDetailsPdf
  include PdfHelper

  def source_pdf_name
    "bank_details_form"
  end

  def initialize(intake)
    @intake = intake
  end

  def hash_for_pdf
    answers = {
        bank_name: @intake.bank_name,
        routing_number: @intake.bank_routing_number,
        account_number: @intake.bank_account_number,
        is_checking_account: bool_checkbox(@intake.bank_account_type_checking?),
        is_savings_account: bool_checkbox(@intake.bank_account_type_savings?),
    }
    answers
  end

  def as_png
    as_pdf = MiniMagick::Image.open(output_file.path)
    tempfile = Tempfile.new(["bank_details", ".png"])
    MiniMagick::Tool::Convert.new do |convert|
      convert.background "white"
      convert.flatten
      convert.density 150
      convert.quality 100
      convert << as_pdf.pages.first.path
      convert << "png8:#{tempfile.path}"
    end
    tempfile
  end
end
