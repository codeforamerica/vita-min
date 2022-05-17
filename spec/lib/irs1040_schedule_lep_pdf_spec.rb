require "rails_helper"

describe Irs1040ScheduleLepPdf do
  include PdfSpecHelper
  let(:pdf) { described_class.new(submission) }
  let(:submission) { create :efile_submission }
  let(:fake_xml_document) {
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.IRS1040ScheduleLEP do
        xml.PersonNm "Martha Mango"
        xml.SSN '111223333'
        xml.LanguagePreferenceCd "004"
      end
    end.doc
  }

  before do
    allow_any_instance_of(SubmissionBuilder::Ty2021::Documents::ScheduleLep).to receive(:document).and_return fake_xml_document
  end

  describe "#output_file" do
    context "without values" do
      let(:fake_xml_document) {
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.RootNode do
          end
        end.doc
      }

      it "returns default values" do
        output_file = pdf.output_file

        expect(non_preparer_fields(output_file.path)).to eq ({
            "PersonNm" => "",
            "SSN" => "",
            "LanguagePreferenceCd" => "",
        })
      end
    end

    context "filled out" do
      it "returns fill out values from XML values" do
        output_file = pdf.output_file

        expect(non_preparer_fields(output_file.path)).to eq ({
            "PersonNm" => "Martha Mango",
            "SSN" => "111223333",
            "LanguagePreferenceCd" => "004"
        })
      end
    end
  end
end