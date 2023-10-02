# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                   :bigint           not null, primary key
#  claimed_as_dep       :integer
#  current_step         :string
#  raw_direct_file_data :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  visitor_id           :string
#
FactoryBot.define do
  factory :state_file_az_intake do
    tax_return_year { 2022 }
    claimed_as_dep { 'no' }
    filing_status { 'single' }
    primary_first_name { "Ariz" }
    primary_last_name { "Onian" }
    primary_ssn { "123445555" }
    primary_dob { Date.new(1985, 1, 3) }
    mailing_street { "123 main st" }
    mailing_city { "Phoenix" }
    mailing_zip { "85001" }
  end
end
