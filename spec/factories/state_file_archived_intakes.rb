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
  end
end