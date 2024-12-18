module SubmissionBuilder
  module Ty2021
    module Documents
      # The XML schema calls it EIC, the product calls it EITC, and the pdf calls it SEI
      class ScheduleEic < SubmissionBuilder::Document
        def schema_file
          SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRS1040ScheduleEIC", "IRS1040ScheduleEIC.xsd")
        end

        def document
          eitc_dependents = submission.qualifying_dependents.select(&:qualifying_eitc?).first(3)
          build_xml_doc("IRS1040ScheduleEIC", documentId: "IRS1040ScheduleEIC", documentName: "IRS1040ScheduleEIC") do |xml|
            eitc_dependents.each do |dependent|
              xml.QualifyingChildInformation {
                xml.QualifyingChildNameControlTxt name_control_type(dependent.last_name)
                xml.ChildFirstAndLastName {
                  xml.PersonFirstNm person_name_type(dependent.first_name)
                  xml.PersonLastNm person_name_type(dependent.last_name)
                }
                xml.IdentityProtectionPIN dependent.ip_pin if dependent.ip_pin.present?
                xml.QualifyingChildSSN dependent.ssn
                xml.ChildBirthYr dependent.birth_date.year
                xml.ChildIsAStudentUnder24Ind dependent.schedule_eic_4a?
                xml.ChildPermanentlyDisabledInd dependent.schedule_eic_4b? if dependent.schedule_eic_4a? == false
                xml.ChildRelationshipCd dependent.irs_relationship_enum
                xml.MonthsChildLivedWithYouCnt dependent.months_in_home.to_s.rjust(2, '0')
              }
            end
          end
        end
      end
    end
  end
end
