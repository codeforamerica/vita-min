require "rails_helper"

RSpec.describe BankDetailsPdf do
  include PdfSpecHelper

  let(:bank_details_pdf) { BankDetailsPdf.new(intake) }

  describe "#as_png" do
    let(:intake) { create :intake }

    it "converts the pdf to png" do
      png_tempfile = bank_details_pdf.as_png
      expect(png_tempfile).to be_an_instance_of(Tempfile)
      expect(MiniMagick::Image.read(png_tempfile).type).to eq "PNG"
    end
  end

  describe "#output_file" do
    context "with no bank details" do
      let(:intake) { create :intake }

      it "returns a pdf with default fields and values" do
        output_file = bank_details_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
                                 "bank_name" => "",
                                 "account_number" => "",
                                 "routing_number" => "",
                                 "is_checking_account" => "",
                                 "is_savings_account" => "",
                             })
      end
    end

    context "with bank information" do
      let(:intake) do
        create(
            :intake,
            bank_name: "First Savings",
            bank_routing_number: "1234",
            bank_account_number: "09876",
            bank_account_type: "savings"
            )
      end

      it "returns a filled out pdf" do
        output_file = bank_details_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
                                 "bank_name" => "First Savings",
                                 "account_number" => "09876",
                                 "routing_number" => "1234",
                                 "is_checking_account" => "",
                                 "is_savings_account" => "Yes",
                             })
      end
    end
  end
end