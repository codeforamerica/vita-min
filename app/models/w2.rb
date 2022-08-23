# == Schema Information
#
# Table name: w2s
#
#  id                            :bigint           not null, primary key
#  employee_apartment_number     :string
#  employee_city                 :string
#  employee_ssn                  :string
#  employee_state                :string
#  employee_street_adddress      :string
#  employee_zip_code             :string
#  employer_apartment_number     :string
#  employer_city                 :string
#  employer_ein                  :string
#  employer_name                 :string
#  employer_name_control_text    :string
#  employer_state                :string
#  employer_street_address       :string
#  employer_zip_code             :string
#  legal_first_name              :string
#  legal_last_initial            :string
#  legal_middle_initial          :string
#  standard_or_non_standard_code :string
#  suffix                        :string
#  wages_amount                  :decimal(12, 2)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  intake_id                     :bigint
#
# Indexes
#
#  index_w2s_on_intake_id  (intake_id)
#
class W2 < ApplicationRecord
  belongs_to :intake, inverse_of: :dependents
end
