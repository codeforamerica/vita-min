# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                             :bigint           not null, primary key
#  claimed_as_dep                 :integer
#  current_step                   :string
#  fed_taxable_income             :integer
#  fed_taxable_ssb                :integer
#  fed_unemployment               :integer
#  fed_wages                      :integer
#  filing_status                  :integer
#  mailing_apartment              :string
#  mailing_city                   :string
#  mailing_street                 :string
#  mailing_zip                    :string
#  phone_daytime                  :string
#  phone_daytime_area_code        :string
#  primary_dob                    :date
#  primary_first_name             :string
#  primary_last_name              :string
#  primary_middle_initial         :string
#  primary_occupation             :string
#  primary_ssn                    :string
#  spouse_dob                     :date
#  spouse_first_name              :string
#  spouse_last_name               :string
#  spouse_middle_initial          :string
#  spouse_occupation              :string
#  spouse_ssn                     :string
#  tax_return_year                :integer
#  total_fed_adjustments          :integer
#  total_fed_adjustments_identify :string
#  total_state_tax_withheld       :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  visitor_id                     :string
#
class StateFileAzIntake < StateFileBaseIntake
  def filing_status
    # TODO
    "single"
  end

  # TODO
  def agi
    1234
  end
end
