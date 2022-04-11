require "rails_helper"

describe F15080VitaConsentToDisclosePdf do
  include PdfSpecHelper

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake, :unconsented }
      it "returns a pdf with default fields and values" do
        consent_pdf = F15080VitaConsentToDisclosePdf.new(intake)
        output_file = consent_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
                                 "primary_legal_name" => nil,
                                 "spouse_legal_name" => nil,
                                 "primary_consented_at" => nil,
                                 "spouse_consented_at" => nil
                             })
      end
    end

    context "with a consented intake record" do
      let(:intake) do
        create :intake,
               primary_first_name: "Oscar",
               primary_last_name: "Orange",
               primary_consented_to_service_at: DateTime.new(2020, 4, 15),
               spouse_consented_to_service_at: DateTime.new(2020, 4, 17),
               spouse_first_name: "Owen",
               spouse_last_name: "Orange"
      end
      it "returns a filled out pdf" do
        consent_pdf = described_class.new(intake)
        output_file = consent_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
                                 "primary_consented_at" => "4/15/2020",
                                 "primary_legal_name" => "Oscar Orange",
                                 "spouse_legal_name" => "Owen Orange",
                                 "spouse_consented_at" => "4/17/2020"
                             }

        )
      end
    end
  end

end