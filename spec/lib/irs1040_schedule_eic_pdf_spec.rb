require "rails_helper"

describe Irs1040ScheduleEicPdf do
  include PdfSpecHelper
  let(:pdf) { described_class.new(submission) }
  let(:submission) { create :efile_submission, client: create(:client, intake: build(:ctc_intake, primary_first_name: "Bethany", primary_last_name: "Banana")) }
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
        expect(filled_in_values(output_file.path)).to eq({
             "ChildBirthYr1[0]" => nil,
             "ChildBirthYr1[1]" => nil,
             "ChildBirthYr1[2]" => nil,
             "ChildBirthYr1[3]" => nil,
             "ChildBirthYr2[0]" => nil,
             "ChildBirthYr2[1]" => nil,
             "ChildBirthYr2[2]" => nil,
             "ChildBirthYr2[3]" => nil,
             "ChildBirthYr3[0]" => nil,
             "ChildBirthYr3[1]" => nil,
             "ChildBirthYr3[2]" => nil,
             "ChildBirthYr3[3]" => nil,
             "ChildFirstAndLastName1" => nil,
             "ChildFirstAndLastName2" => nil,
             "ChildFirstAndLastName3" => nil,
             "ChildIsAStudentUnder24IndNo1" => nil,
             "ChildIsAStudentUnder24IndNo2" => nil,
             "ChildIsAStudentUnder24IndNo3" => nil,
             "ChildIsAStudentUnder24IndYes1" => nil,
             "ChildIsAStudentUnder24IndYes2" => nil,
             "ChildIsAStudentUnder24IndYes3" => nil,
             "ChildPermanentlyDisabledIndNo1" => nil,
             "ChildPermanentlyDisabledIndNo2" => nil,
             "ChildPermanentlyDisabledIndNo3" => nil,
             "ChildPermanentlyDisabledIndYes1" => nil,
             "ChildPermanentlyDisabledIndYes2" => nil,
             "ChildPermanentlyDisabledIndYes3" => nil,
             "ChildRelationshipCd1" => nil,
             "ChildRelationshipCd2" => nil,
             "ChildRelationshipCd3" => nil,
             "FullPrimaryName" => "Bethany Banana",
             "MonthsChildLivedWithYouCnt1" => nil,
             "MonthsChildLivedWithYouCnt2" => nil,
             "MonthsChildLivedWithYouCnt3" => nil,
             "PrimarySSN" => "",
             "QualifyingChildSSN1" => nil,
             "QualifyingChildSSN2" => nil,
             "QualifyingChildSSN3" => nil,
             "SepdSpsFilingSepRetMeetsRqrInd" => nil,
           })
      end
    end

    context "filled out" do
      it "returns fill out values from XML values" do
        output_file = pdf.output_file
        expect(filled_in_values(output_file.path)).to eq({
               "ChildBirthYr1[0]" => "2",
               "ChildBirthYr1[1]" => "0",
               "ChildBirthYr1[2]" => "1",
               "ChildBirthYr1[3]" => "0",
               "ChildBirthYr2[0]" => "2",
               "ChildBirthYr2[1]" => "0",
               "ChildBirthYr2[2]" => "1",
               "ChildBirthYr2[3]" => "2",
               "ChildBirthYr3[0]" => nil,
               "ChildBirthYr3[1]" => nil,
               "ChildBirthYr3[2]" => nil,
               "ChildBirthYr3[3]" => nil,
               "ChildFirstAndLastName1" => "Kara Kiwi",
               "ChildFirstAndLastName2" => "Paul Peach",
               "ChildFirstAndLastName3" => nil,
               # Child 1: 4(a) yes (is student); 4(b) skipped (is permanently disabled)
               "ChildIsAStudentUnder24IndYes1" => "1",
               "ChildIsAStudentUnder24IndNo1" => "",
               "ChildPermanentlyDisabledIndNo1" => nil,
               "ChildPermanentlyDisabledIndYes1" => nil,
               # Child 1: 4(a) no (is student); 4(b) yes (is permanently disabled)
               "ChildIsAStudentUnder24IndYes2" => "",
               "ChildIsAStudentUnder24IndNo2" => "2",
               "ChildPermanentlyDisabledIndYes2" => "1",
               "ChildPermanentlyDisabledIndNo2" => "",
               # Child 3: missing, so nil everywhere
               "ChildIsAStudentUnder24IndYes3" => nil,
               "ChildIsAStudentUnder24IndNo3" => nil,
               "ChildPermanentlyDisabledIndNo3" => nil,
               "ChildPermanentlyDisabledIndYes3" => nil,
               "ChildRelationshipCd1" => "SON",
               "ChildRelationshipCd2" => "NEPHEW",
               "ChildRelationshipCd3" => nil,
               "FullPrimaryName" => "Bethany Banana",
               "MonthsChildLivedWithYouCnt1" => "07",
               "MonthsChildLivedWithYouCnt2" => "07",
               "MonthsChildLivedWithYouCnt3" => nil,
               "PrimarySSN" => "",
               "QualifyingChildSSN1" => "111223333",
               "QualifyingChildSSN2" => "111224444",
               "QualifyingChildSSN3" => nil,
               "SepdSpsFilingSepRetMeetsRqrInd" => nil
         })
      end
    end
  end
end
