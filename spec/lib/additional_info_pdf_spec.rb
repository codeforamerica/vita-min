require "rails_helper"

RSpec.describe AdditionalInfoPdf do
  include PdfSpecHelper

  let(:additional_info_pdf) { AdditionalInfoPdf.new(intake) }

  describe "#as_png" do
    let(:intake) { create :intake }

    it "converts the pdf to png" do
      png_tempfile = additional_info_pdf.as_png
      expect(png_tempfile).to be_an_instance_of(Tempfile)
      expect(MiniMagick::Image.read(png_tempfile).type).to eq "PNG"
    end
  end

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake }

      it "returns a pdf with default fields and values" do
        output_file = additional_info_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "primary_name" => "",
          "primary_ssn" => "",
          "spouse_name" => "",
          "spouse_ssn" => "",
        })
      end
    end

    context "with two users" do
      let(:intake) do
        create(
          :intake,
        )
      end
      before do
        create(
          :user,
          intake: intake,
          first_name: "Beanie",
          last_name: "Bear",
          ssn: "123445678",
        )
        create(
          :spouse_user,
          intake: intake,
          first_name: "Broccoli",
          last_name: "Bear",
          ssn: "223445677",
        )
      end

      it "returns a filled out pdf" do
        output_file = additional_info_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "primary_name" => "Beanie Bear",
          "primary_ssn" => "123-44-5678",
          "spouse_name" => "Broccoli Bear",
          "spouse_ssn" => "223-44-5677",
        })
      end
    end
  end
end