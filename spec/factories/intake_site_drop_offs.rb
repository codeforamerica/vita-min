FactoryBot.define do
  factory :intake_site_drop_off do
    name { "Gary Guava" }
    intake_site { "Adams City High School" }
    signature_method { :e_signature }
    document_bundle { Rack::Test::UploadedFile.new("spec/fixtures/attachments/document_bundle.pdf", "application/pdf") }

    trait :optional_fields do
      email { "gguava@example.com" }
      phone_number { "4158161286" }
      pickup_date { Date.new(2020, 4, 10) }
      additional_info { "Gary is missing a document" }
      timezone { "America/Denver" }
      certification_level { "Basic" }
    end

    factory :full_drop_off do
      optional_fields
    end
  end
end