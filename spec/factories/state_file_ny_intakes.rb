# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                 :bigint           not null, primary key
#  birth_date         :date
#  city               :string
#  current_step       :string
#  primary_first_name :string
#  primary_last_name  :string
#  ssn                :string
#  street_address     :string
#  tax_return_year    :integer
#  zip_code           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tp_id              :string
#
FactoryBot.define do
  factory :state_file_ny_intake do
    primary_first_name { "New" }
    primary_last_name { "Yorker" }
    tax_return_year { 2022 }
    tp_id { "123456789" }
    street_address { "123 main st" }
    city { "New York" }
    zip_code { "10001" }
    ssn { "123445555" }
    birth_date { Date.new(1985, 1, 3) }
  end
end
