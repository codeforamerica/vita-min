# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                :bigint           not null, primary key
#  email_address     :string
#  hashed_ssn        :string
#  mailing_apartment :string
#  mailing_city      :string
#  mailing_state     :string
#  mailing_street    :string
#  mailing_zip       :string
#  state_code        :string
#  tax_year          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :state_file_archived_intake do
    submission_pdf { nil }

    transient do
      intake { nil }
      archiver { nil }
    end

    after(:create) do |archived_intake, evaluator|
      intake = evaluator.intake
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
