module SubmissionBuilder
  module Ty2021
    module Documents
      class IrsW2 < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods

        def schema_file
          File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRSW2", "IRSW2.xsd")
        end

        def document
          w2 = @kwargs[:w2]

          build_xml_doc("IRSW2", documentId: "IRSW2-#{w2.id}", documentName: "IRSW2") do |xml|
            xml.EmployeeSSN w2.employee_ssn
            xml.EmployerEIN w2.employer_ein
            xml.EmployerNameControlTxt employer_name_control_type(w2.employer_name)
            xml.EmployerName do |xml|
              xml.BusinessNameLine1Txt w2.employer_name
            end
            xml.EmployerUSAddress do |xml|
              xml.AddressLine1Txt w2.employer_street_address
              xml.CityNm w2.employer_city
              xml.StateAbbreviationCd w2.employer_state
              xml.ZIPCd w2.employer_zip_code
            end
            xml.ControlNum w2.box_d_control_number if w2.box_d_control_number.present?
            xml.EmployeeNm person_name_type("#{w2.employee_first_name} #{w2.employee_last_name}", length: 35)
            xml.EmployeeUSAddress do |xml|
              xml.AddressLine1Txt w2.employee_street_address
              xml.CityNm w2.employee_city
              xml.StateAbbreviationCd w2.employee_state
              xml.ZIPCd w2.employee_zip_code
            end
            xml.WagesAmt w2.wages_amount.round
            xml.WithholdingAmt w2.federal_income_tax_withheld.round
            xml.SocialSecurityWagesAmt w2.box3_social_security_wages.round if w2.box3_social_security_wages
            xml.SocialSecurityTaxAmt w2.box4_social_security_tax_withheld.round if w2.box4_social_security_tax_withheld
            xml.MedicareWagesAndTipsAmt w2.box5_medicare_wages_and_tip_amount.round if w2.box5_medicare_wages_and_tip_amount
            xml.MedicareTaxWithheldAmt w2.box6_medicare_tax_withheld.round if w2.box6_medicare_tax_withheld
            xml.SocialSecurityTipsAmt w2.box7_social_security_tips_amount.round if w2.box7_social_security_tips_amount
            xml.AllocatedTipsAmt w2.box8_allocated_tips.round if w2.box8_allocated_tips
            xml.DependentCareBenefitsAmt w2.box10_dependent_care_benefits.round if w2.box10_dependent_care_benefits
            xml.NonqualifiedPlansAmt w2.box11_nonqualified_plans.round if w2.box11_nonqualified_plans
            if w2.box12a_code.present?
              xml.EmployersUseGrp do |xml|
                xml.EmployersUseCd w2.box12a_code
                xml.EmployersUseAmt w2.box12a_value.round
              end
            end
            if w2.box12b_code.present?
              xml.EmployersUseGrp do |xml|
                xml.EmployersUseCd w2.box12b_code
                xml.EmployersUseAmt w2.box12b_value.round
              end
            end
            if w2.box12c_code.present?
              xml.EmployersUseGrp do |xml|
                xml.EmployersUseCd w2.box12c_code
                xml.EmployersUseAmt w2.box12c_value.round
              end
            end
            if w2.box12d_code.present?
              xml.EmployersUseGrp do |xml|
                xml.EmployersUseCd w2.box12d_code
                xml.EmployersUseAmt w2.box12d_value.round
              end
            end
            xml.StatutoryEmployeeInd "X" if w2.box13_statutory_employee_yes?
            xml.RetirementPlanInd "X" if w2.box13_retirement_plan_yes?
            xml.ThirdPartySickPayInd "X" if w2.box13_third_party_sick_pay_yes?

            w2.w2_box14.compact.each do |box14|
              next unless box14.other_description.present? && box14.other_amount.present?

              xml.OtherDeductionsBenefitsGrp do |xml|
                xml.Desc box14.other_description
                xml.Amt box14.other_amount.round
              end
            end

            [w2.w2_state_fields_group].compact.each do |group|
              xml.W2StateLocalTaxGrp do |xml|
                xml.W2StateTaxGrp do |xml|
                  xml.StateAbbreviationCd group.box15_state if group.box15_state.present?
                  xml.EmployerStateIdNum group.box15_employer_state_id_number if group.box15_employer_state_id_number.present?
                  xml.StateWagesAmt group.box16_state_wages.round if group.box16_state_wages.present?
                  xml.StateIncomeTaxAmt group.box17_state_income_tax.round if group.box17_state_income_tax.present?

                  xml.W2LocalTaxGrp do |xml|
                    xml.LocalWagesAndTipsAmt group.box18_local_wages.round if group.box18_local_wages.present?
                    xml.LocalIncomeTaxAmt group.box19_local_income_tax.round if group.box19_local_income_tax.present?
                    xml.LocalityNm group.box20_locality_name if group.box20_locality_name.present?
                  end
                end
              end
            end

            xml.StandardOrNonStandardCd 'S'
          end
        end

        private

        def employer_name_control_type(employer_name)
          return "" unless employer_name.present?

          # Restrict to just characters allowed in the BusinessNameControlType type from the schema
          employer_name.upcase.gsub(/[^A-Z0-9\-&]/, '').first(4)
        end
      end
    end
  end
end
