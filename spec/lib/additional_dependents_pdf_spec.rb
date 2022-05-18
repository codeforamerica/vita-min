require "rails_helper"

describe AdditionalDependentsPdf do
  include PdfSpecHelper
  let(:pdf) { described_class.new(submission) }
  let(:submission) { create :efile_submission }
  let(:fake_xml_document) do
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.IRS1040ScheduleLEP do
        xml.DependentDetail do
          xml.DependentFirstNm "Not on Return"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "Not on Return Dependent"
          xml.DependentSSN "111111111"
          xml.DependentRelationshipCd "DAUGHTER"
          xml.EligibleForChildTaxCreditInd "X"
        end
        xml.DependentDetail do
          xml.DependentFirstNm "Another not on Return"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "Not on Return Dependent"
          xml.DependentSSN "111111112"
          xml.DependentRelationshipCd "DAUGHTER"
          xml.EligibleForChildTaxCreditInd "X"
        end
        xml.DependentDetail do
          xml.DependentFirstNm "Yet Another not on Return"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "Not on Return Dependent"
          xml.DependentSSN "111111113"
          xml.DependentRelationshipCd "DAUGHTER"
          xml.EligibleForChildTaxCreditInd "X"
        end
        xml.DependentDetail do
          xml.DependentFirstNm "Last one not on Return"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "Not on Return Dependent"
          xml.DependentSSN "111111114"
          xml.DependentRelationshipCd "DAUGHTER"
          xml.EligibleForChildTaxCreditInd "X"
        end
        xml.DependentDetail do
          xml.DependentFirstNm "FirstAdditional"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "FirstAdditional Dependent"
          xml.DependentSSN "111111115"
          xml.DependentRelationshipCd "SON"
          xml.EligibleForChildTaxCreditInd "X"
        end
        xml.DependentDetail do
          xml.DependentFirstNm "SecondAdditional"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "SECONDAdditional Dependent"
          xml.DependentSSN "111111116"
          xml.DependentRelationshipCd "FOSTER CHILD"
          xml.EligibleForChildTaxCreditInd ""
        end
        xml.DependentDetail do
          xml.DependentFirstNm "ThirdAdditional"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "ThirdAdditional Dependent"
          xml.DependentSSN "111111117"
          xml.DependentRelationshipCd "GRANDCHILD"
          xml.EligibleForChildTaxCreditInd ""
        end
        xml.DependentDetail do
          xml.DependentFirstNm "FourthAdditional"
          xml.DependentLastNm "Dependent"
          xml.DependentNameControlTxt "FourthAdditional Dependent"
          xml.DependentSSN "111111118"
          xml.DependentRelationshipCd "PARENT"
          xml.EligibleForChildTaxCreditInd ""
        end
      end
    end.doc
  end

  before do
    allow_any_instance_of(SubmissionBuilder::Ty2021::Documents::Irs1040).to receive(:document).and_return fake_xml_document
  end

  describe "#output_file" do
    context "without values" do
      let(:fake_xml_document) do
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.RootNode do
          end
        end.doc
      end

      it "returns default values" do
        output_file = pdf.output_file
        empty = {}
        22.times do |i|
          empty.merge!({
            "DependentNameRow#{i + 1}" => nil,
            "CTCRow#{i + 1}" => nil,
            "ODCRow#{i + 1}" => nil,
            "RelationshipRow#{i + 1}" => nil,
            "TINRow#{i + 1}" => nil,
          })
        end
        expect(filled_in_values(output_file.path)).to eq empty
      end
    end

    context "filled out" do
      it "returns fill out values from XML values" do
        output_file = pdf.output_file
        filled = {}
        18.times do |i|
          filled.merge!({
                           "DependentNameRow#{i + 5}" => nil,
                           "CTCRow#{i + 5}" => nil,
                           "ODCRow#{i + 5}" => nil,
                           "RelationshipRow#{i + 5}" => nil,
                           "TINRow#{i + 5}" => nil,
                       })
        end
        expect(filled_in_values(output_file.path)).to eq filled.merge!(
          {
          "DependentNameRow1" => "FirstAdditional Dependent",
          "CTCRow1" => "Yes",
          "ODCRow1" => "",
          "RelationshipRow1" => "SON",
          "TINRow1" => "111111115",

          "DependentNameRow2" => "SecondAdditional Dependent",
          "CTCRow2" => "",
          "ODCRow2" => "",
          "RelationshipRow2" => "FOSTER CHILD",
          "TINRow2" => "111111116",

          "DependentNameRow3" => "ThirdAdditional Dependent",
          "CTCRow3" => "",
          "ODCRow3" => "",
          "RelationshipRow3" => "GRANDCHILD",
          "TINRow3" => "111111117",

          "DependentNameRow4" => "FourthAdditional Dependent",
          "CTCRow4" => "",
          "ODCRow4" => "",
          "RelationshipRow4" => "PARENT",
          "TINRow4" => "111111118",
       })
      end
    end
  end

end