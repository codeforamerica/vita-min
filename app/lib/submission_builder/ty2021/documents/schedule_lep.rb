module SubmissionBuilder
  module Ty2021
    module Documents
      class ScheduleLep < SubmissionBuilder::Document
        def schema_file
          SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRS1040ScheduleLEP", "IRS1040ScheduleLEP.xsd")
        end

        def document
          intake = submission.intake
          build_xml_doc("IRS1040ScheduleLEP", documentId: "IRS1040ScheduleLEP", documentName: "IRS1040ScheduleLEP") do |xml|
            xml.PersonNm person_name_type(intake.primary.first_and_last_name, length: 35)
            xml.SSN intake.primary.ssn
            xml.LanguagePreferenceCd intake.irs_language_preference_code
          end
        end
      end
    end
  end
end
