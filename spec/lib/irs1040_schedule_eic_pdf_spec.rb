require "rails_helper"

describe Irs1040ScheduleEicPdf do
  include PdfSpecHelper
  let(:pdf) { described_class.new(submission) }
  let(:submission) { create :efile_submission, client: create(:client, intake: create(:ctc_intake, primary_first_name: "Bethany", primary_last_name: "Banana")) }
  let(:fake_xml_document) do
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.IRS1040ScheduleEIC {
        xml.QualifyingChildInformation {
          xml.QualifyingChildNameControlTxt "KIWI"
          xml.ChildFirstAndLastName {
            xml.PersonFirstNm "Kara"
            xml.PersonLastNm "Kiwi"
          }
          xml.IdentityProtectionPIN "123456"
          xml.QualifyingChildSSN "111223333"
          xml.ChildBirthYr "2010"
          xml.ChildIsAStudentUnder24Ind true
          xml.ChildPermanentlyDisabledInd false
          xml.ChildRelationshipCd "SON"
          xml.MonthsChildLivedWithYouCnt "07"
        }
        xml.QualifyingChildInformation {
          xml.QualifyingChildNameControlTxt "PEACH"
          xml.ChildFirstAndLastName {
            xml.PersonFirstNm "Paul"
            xml.PersonLastNm "Peach"
          }
          xml.IdentityProtectionPIN "123456"
          xml.QualifyingChildSSN "111224444"
          xml.ChildBirthYr "2012"
          xml.ChildIsAStudentUnder24Ind false
          xml.ChildPermanentlyDisabledInd true
          xml.ChildRelationshipCd "NEPHEW"
          xml.MonthsChildLivedWithYouCnt "07"
        }
      }
    end.doc
  end

  before do
    allow_any_instance_of(SubmissionBuilder::Ty2021::Documents::ScheduleEic).to receive(:document).and_return fake_xml_document
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
        expect(filled_in_values(output_file.path)).to eq empty
      end
    end

    context "filled out" do
      it "returns fill out values from XML values" do
        output_file = pdf.output_file
        expect(filled_in_values(output_file.path)).to eq({})
      end
    end
  end
end