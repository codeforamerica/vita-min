module SubmissionBuilder
  module Documents
    class Scenario5Irs8863 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS8863", "IRS8863.xsd")
      @root_node = "IRS8863"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS8863", documentName: "IRS8863", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS8863(root_node_attrs) {
            xml.RefundableAmerOppCreditGroup {
              xml.TentativeAmerOppCreditAmt 700
              xml.EnterSpecifiedAmountForFSAmt 90000
              xml.ModifiedAGIAmt 28869
              xml.SubtractAGIFromAmt 61131
              xml.SpecifiedAmtPerFSAmt 10000
              xml.CalcTentativeEducationRt 1.000
              xml.CalcTentativeEducationCrAmt 700
              xml.RefundableAmerOppCreditAmt 280
            }
            xml.NonrefundableEducationCrGroup {
              xml.TentativeEducCrLessRfdblCrAmt 420
            }
            xml.StudentAndEducationalInstnGrp {
              xml.StudentName {
                xml.PersonFirstNm "Sarah"
                xml.PersonLastNm "PersonLastNm"
              }
              xml.StudentNameControlTxt "SARA"
              xml.StudentSSN "400001039"
              xml.EducationalInstitutionGroup {
                xml.InstitutionName {
                  xml.BusinessNameLine1Txt "University of Virgina"
                }
                xml.USAddress {
                  xml.AddressLine1Txt "202 15TH ST SW"
                  xml.CityNm "CHARLOTTESVILLE"
                  xml.StateAbbreviationCd "VA"
                  xml.ZIPCd "22904"
                }
                xml.CurrentYear1098TReceivedInd false
                xml.PriorYear1098TReceivedInd false
                xml.EIN "000000004"
              }
              xml.PriorYearCreditClaimedInd false
              xml.AcademicPdEligibleStudentInd true
              xml.PostSecondaryEducationInd false
              xml.DrugFelonyConvictionInd false
              xml.AmerOppQualifiedExpensesAmt 700
              xml.AmerOppCreditNetCalcExpnssAmt 700
            }
          }
        end.doc
      end
    end
  end
end