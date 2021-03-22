require "rails_helper"

RSpec.describe ConsentPdf do
  include PdfSpecHelper

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake }

      it "returns a pdf with default fields and values" do
        consent_pdf = ConsentPdf.new(intake)
        output_file = consent_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "primary_consented_at" => nil,
          "primary_consented_ip" => nil,
          "primary_dob" => nil,
          "primary_email" => nil,
          "primary_name" => nil,
          "primary_phone" => nil,
          "primary_signature" => nil,
          "primary_ssn_last_four" => nil,
          "spouse_consented_at" => nil,
          "spouse_consented_ip" => nil,
          "spouse_dob" => nil,
          "spouse_email" => nil,
          "spouse_name" => nil,
          "spouse_phone" => nil,
          "spouse_signature" => nil,
          "spouse_ssn_last_four" => nil,
        })
      end
    end

    context "with a complete intake record" do
      let(:intake) do
        create :intake,
           primary_first_name: "Oscar",
           primary_last_name: "Orange",
           primary_consented_to_service_at: DateTime.new(2020, 4, 15),
           primary_consented_to_service_ip: "127.0.0.1",
           primary_last_four_ssn: "5555",
           primary_birth_date: Date.new(1955, 9, 4),
           phone_number: "+14158161286",
           email_address: "me@oscar.orange",
           spouse_first_name: "Owen",
           spouse_last_name: "Orange",
           spouse_email_address: "owen@oscar.orange",
           spouse_consented_to_service_at: DateTime.new(2020, 4, 17),
           spouse_consented_to_service_ip: "0.0.0.0",
           spouse_last_four_ssn: "4444",
           spouse_birth_date: Date.new(1952, 9, 5)
      end

      it "returns a filled out pdf" do
        consent_pdf = ConsentPdf.new(intake)
        output_file = consent_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
           "primary_consented_at" => "4/15/2020",
           "primary_consented_ip" => "127.0.0.1",
           "primary_dob" => "9/4/1955",
           "primary_email" => "me@oscar.orange",
           "primary_name" => "Oscar Orange",
           "primary_signature" => "Oscar Orange",
           "primary_phone" => "(415) 816-1286",
           "primary_ssn_last_four" => "5555",
           "spouse_consented_at" => "4/17/2020",
           "spouse_consented_ip" => "0.0.0.0",
           "spouse_dob" => "9/5/1952",
           "spouse_email" => "owen@oscar.orange",
           "spouse_name" => "Owen Orange",
           "spouse_signature" => "Owen Orange",
           "spouse_phone" => nil,
           "spouse_ssn_last_four" => "4444",
        })
      end
    end
  end
end
