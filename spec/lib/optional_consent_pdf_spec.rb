require "rails_helper"

RSpec.describe OptionalConsentPdf do
  include PdfSpecHelper

  describe "#output_file" do
    context "with an empty consent record" do
      let(:client) { create :client, :with_empty_consent, intake: (create :intake, primary_consented_to_service_at: DateTime.now) }

      it "returns a pdf with default fields and values" do
        optional_consent_pdf = OptionalConsentPdf.new(client.consent)
        output_file = optional_consent_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "use" => "No",
          "disclose" => "No",
          "relational_efin" => "No",
          "global_carryforward" => "No",
        })
      end
    end

    context "with a complete intake record" do
      let(:client) { create :client, :with_consent, intake: (create :intake, primary_consented_to_service_at: DateTime.now) }

      it "returns a filled out pdf" do
        consent_pdf = OptionalConsentPdf.new(client.consent)
        output_file = consent_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "use" => "Yes",
          "disclose" => "Yes",
          "relational_efin" => "Yes",
          "global_carryforward" => "Yes",
        })
      end
    end
  end
end
