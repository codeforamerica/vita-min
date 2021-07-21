module TestSubmissions
  class Scenario5Submission
    def self.create_submission
      intake_attr = {
          type: "Intake::CtcIntake",
          visitor_id: "AAAAAAAAAAAAAAAAAAAAAAAAA",
          primary_first_name: "Sarah",
          primary_last_name: "Washington",
          street_address: "1111 MULBERRY ST",
          city: "ALEXANDRIA",
          state: "VA",
          zip_code: 22309,
          primary_ssn: "400001039",
          primary_ip_pin: "876543",
          primary_birth_date: Date.new(1990, 12, 17),
          # primary_signature_pin: "12345", # get this from static signature PIN on intake for now
          refund_payment_method: "direct_deposit",
          primary_consented_to_service_ip: "250.11.255.255",
          sms_phone_number_verified_at: DateTime.now,
          dependents_attributes: [
              {
                  first_name: "Sue",
                  last_name: "Washington",
                  ssn: "400001057",
                  relationship: "DAUGHTER",
                  birth_date: Date.new(2009, 10, 19)
              },
              {
                  first_name: "Sammy",
                  last_name: "Washington",
                  ssn: "400001058",
                  relationship: "SON",
                  birth_date: Date.new(2010, 11, 8)
              }
          ],
          bank_account_attributes: {
              routing_number: "012345672",
              account_number: "1234567",
              account_type: "checking"
          }
      }

      client = Client.create!(
          intake_attributes: intake_attr,
          tax_returns_attributes: [{ year: 2020, filing_status: "qualifying_widow" }]
      )

      intake = client.intake
      intake.sms_phone_number = "+13031234567"
      intake.save(validate: false) # this isn't a real phone number, so we have to bypass validations

      submission = EfileSubmission.create(tax_return: client.tax_returns.last)

      submission.create_address(street_address: "1111 MULBERRY ST", city: "ALEXANDRIA", state: "VA", zip_code: "22309")
      submission
    end
  end
end