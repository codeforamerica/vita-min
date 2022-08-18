module SubmissionBuilder
  module Ty2021
    module Documents
      # The XML schema calls it EIC, the product calls it EITC, and the pdf calls it SEI
      class ScheduleEic < SubmissionBuilder::Document
        def schema_file
          File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRS1040ScheduleEIC", "IRS1040ScheduleEIC.xsd")
        end

        def document
          eitc_dependents = submission.qualifying_dependents.select(&:qualifying_eitc?)
          build_xml_doc("IRS1040ScheduleEIC", documentId: "IRS1040ScheduleEIC", documentName: "IRS1040ScheduleEIC") do |xml|
            eitc_dependents.each do |dependent|
              xml.QualifyingChildInformation {
                xml.QualifyingChildNameControlTxt person_name_control_type(dependent.last_name)
                xml.ChildFirstAndLastName {
                  xml.PersonFirstNm person_name_type(dependent.first_name)
                  xml.PersonLastNm person_name_type(dependent.last_name)
                }
                xml.IdentityProtectionPIN dependent.ip_pin
                xml.QualifyingChildSSN dependent.ssn
                xml.ChildBirthYr dependent.birth_date.year
                xml.ChildIsAStudentUnder24Ind dependent.full_time_student_yes? && dependent.age_during_tax_year < 24
                xml.ChildPermanentlyDisabledInd dependent.permanently_totally_disabled_yes?
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
