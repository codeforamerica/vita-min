FactoryBot.define do
  factory :beta_test_client, class: "Client" do
    vita_partner { VitaPartner.where(name: "[United Way California] Online Intake").first }
    after(:create) do |client|
      first_name, last_name = BetaTestDataGenerator.get_name
      is_married = ["yes", "no"].sample
      intake = create(
        :intake,
        client: client,
        email_address: "gyr-test-client+#{client.id}@codeforamerica.org",
        phone_number: "+15005550006", # Valid Twilio number for testing https://www.twilio.com/docs/iam/test-credentials
        sms_phone_number: "+15005550006",
        preferred_name: "#{first_name} #{last_name}",
        primary_first_name: first_name,
        primary_last_name: last_name,
        email_notification_opt_in: "yes",
        sms_notification_opt_in: "no",
        locale: ["en", "es"].sample,
        preferred_interview_language: ["de", "en", "es", "fa", "fr", "ru", "zh"].sample,
        married: is_married,
        filing_joint: is_married == "yes" ? ["yes", "no"].sample : "no",
        street_address: "972 Mission St.",
        city: "San Francisco",
        state: "CA",
        zip_code: "94103",
      )

      create(:document, :with_upload, document_type: DocumentTypes::Identity, intake: intake, client: client)
      create(:document, :with_upload, document_type: DocumentTypes::Selfie, intake: intake, client: client)
      create(:document, :with_upload, document_type: DocumentTypes::SsnItin, intake: intake, client: client)

      [2017, 2018, 2019, 2020].sample(rand(1..4)).each do |year|
        create(:tax_return, year: year, client: client, status: "intake_open")
      end
    end
  end
end


