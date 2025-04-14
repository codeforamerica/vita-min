# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                      :bigint           not null, primary key
#  email_address           :string
#  failed_attempts         :integer          default(0), not null
#  fake_address_1          :string
#  fake_address_2          :string
#  hashed_ssn              :string
#  locked_at               :datetime
#  mailing_apartment       :string
#  mailing_city            :string
#  mailing_state           :string
#  mailing_street          :string
#  mailing_zip             :string
#  permanently_locked_at   :datetime
#  state_code              :string
#  tax_year                :integer
#  unsubscribed_from_email :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
FactoryBot.define do
  factory :state_file_archived_intake do
    email_address { "geddy_lee@example.com" }
    hashed_ssn { "hashed_ssn_value" }
    mailing_apartment { "Apt 1" }
    mailing_city { "Test City" }
    mailing_state { "CA" }
    mailing_street { "123 Test Street" }
    mailing_zip { "12345" }
    state_code { "CA" }
    tax_year { 2023 }
    submission_pdf { nil }

    trait :with_pdf do
      after(:create) do |archived_intake|
        archived_intake.submission_pdf.attach(io: File.open("public/pdfs/ID-VP.pdf"), filename: "ID-VP.pdf")
      end
    end

    transient do
      intake { nil }
      archiver { nil }
    end

    after(:create) do |archived_intake, evaluator|
      intake = evaluator.intake
      unless intake.nil?
        archiver = evaluator.archiver
        archived_intake.update(
          email_address: intake&.email_address,
          hashed_ssn: intake&.hashed_ssn,
          mailing_apartment: intake&.direct_file_data&.mailing_apartment,
          mailing_city: intake&.direct_file_data&.mailing_city,
          mailing_state: intake&.direct_file_data&.mailing_state,
          mailing_street: intake&.direct_file_data&.mailing_street,
          mailing_zip: intake&.direct_file_data&.mailing_zip,
          tax_year: archiver&.tax_year,
          state_code: archiver&.state_code,
        )
        archived_intake.submission_pdf.attach(intake&.submission_pdf&.blob)
        archived_intake.save!
      end
    end
  end
end
