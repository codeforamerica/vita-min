module TemporaryNonsense
  class FakeSubmission
    def self.sample_submission(bundle_class:, state_abbreviation:)
      OpenStruct.new(
        submission_bundle: nil,
        manifest_class: SubmissionBuilder::StateManifest,
        bundle_class: bundle_class,
        state_abbreviation: state_abbreviation,
        irs_submission_id: '4414662023103zvnoell',
        tax_return: OpenStruct.new(
          year: 2022
        ),
        intake: OpenStruct.new(
          primary: OpenStruct.new(
            ssn: '555002222',
            last_name: 'Testuser'
          ),
          completed_w2s: [
            OpenStruct.new(
              "box10_dependent_care_benefits" => nil,
              "box11_nonqualified_plans" => nil,
              "box12a_code" => nil,
              "box12a_value" => nil,
              "box12b_code" => nil,
              "box12b_value" => nil,
              "box12c_code" => nil,
              "box12c_value" => nil,
              "box12d_code" => nil,
              "box12d_value" => nil,
              "box13_retirement_plan" => "unfilled",
              "box13_statutory_employee" => "unfilled",
              "box13_third_party_sick_pay" => "unfilled",
              "box3_social_security_wages" => nil,
              "box4_social_security_tax_withheld" => nil,
              "box5_medicare_wages_and_tip_amount" => nil,
              "box6_medicare_tax_withheld" => nil,
              "box7_social_security_tips_amount" => nil,
              "box8_allocated_tips" => nil,
              "box_d_control_number" => nil,
              "completed_at" => nil,
              "creation_token" => nil,
              "employee" => "primary",
              "employee_first_name" => "Jeff",
              "employee_last_name" => "Iforgot",
              "employee_ssn" => "555002222",
              "employee_city" => "Cleveland",
              "employee_state" => "OH",
              "employee_street_address" => "456 Somewhere Ave",
              "employee_zip_code" => "44092",
              "employer_city" => "San Francisco",
              "employer_ein" => "123456789",
              "employer_name" => "Code for America",
              "employer_state" => "CA",
              "employer_street_address" => "123 Main St",
              "employer_zip_code" => "94414",
              "federal_income_tax_withheld" => 0.2034e2,
              "intake_id" => 11,
              "wages_amount" => 5000
            )
          ]
        )
      )
    end
  end
end