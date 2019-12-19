require "rails_helper"

RSpec.describe IntakePdf do
  include PdfHelper

  let(:intake_pdf) { IntakePdf.new(intake) }

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake }

      it "returns a pdf with default fields and values" do
        output_file = intake_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "has_wages" => ""
        })
      end
    end

    context "with a complete intake record" do
      let(:intake) do
        create(
          :intake,
          has_wages: "yes"
        )
      end

      it "returns a filled out pdf" do
        output_file = intake_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "has_wages" => "Yes"
        })
      end
    end
  end
end