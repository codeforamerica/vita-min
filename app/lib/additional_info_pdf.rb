class AdditionalInfoPdf
  include PdfHelper

  def source_pdf_name
    "additional_info"
  end

  def initialize(intake)
    @intake = intake
    @primary = intake.primary_user
    @spouse = intake.spouse
  end

  def hash_for_pdf
    answers = {
      primary_name: @primary&.full_name,
      primary_ssn: @primary&.formatted_ssn,
      spouse_name: @spouse&.full_name,
      spouse_ssn: @spouse&.formatted_ssn,
    }
    answers
  end

  def as_png
    as_pdf = MiniMagick::Image.open(output_file.path)
    tempfile = Tempfile.new(["additional_info", ".png"])
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