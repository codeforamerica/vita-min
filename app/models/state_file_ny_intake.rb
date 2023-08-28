# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                             :bigint           not null, primary key
#  account_number                 :string
#  account_type                   :integer
#  amount_electronic_withdrawal   :integer
#  amount_owed_pay_electronically :integer
#  claimed_as_dep                 :integer
#  current_step                   :string
#  date_electronic_withdrawal     :date
#  fed_taxable_income             :integer
#  fed_taxable_ssb                :integer
#  fed_unemployment               :integer
#  fed_wages                      :integer
#  filing_status                  :integer
#  mailing_apartment              :string
#  mailing_city                   :string
#  mailing_country                :string
#  mailing_state                  :string
#  mailing_street                 :string
#  mailing_zip                    :string
#  ny_414h_retirement             :integer
#  ny_other_additions             :integer
#  ny_taxable_ssb                 :integer
#  nyc_resident_e                 :integer
#  permanent_apartment            :string
#  permanent_city                 :string
#  permanent_street               :string
#  permanent_zip                  :string
#  phone_daytime                  :string
#  phone_daytime_area_code        :string
#  primary_dob                    :date
#  primary_email                  :string
#  primary_first_name             :string
#  primary_last_name              :string
#  primary_middle_initial         :string
#  primary_occupation             :string
#  primary_signature              :string
#  primary_ssn                    :string
#  refund_choice                  :integer
#  residence_county               :string
#  routing_number                 :string
#  sales_use_tax                  :integer
#  school_district                :string
#  school_district_number         :integer
#  spouse_dob                     :date
#  spouse_first_name              :string
#  spouse_last_name               :string
#  spouse_middle_initial          :string
#  spouse_occupation              :string
#  spouse_signature               :string
#  spouse_ssn                     :string
#  tax_return_year                :integer
#  total_fed_adjustments          :integer
#  total_fed_adjustments_identify :string
#  total_ny_tax_withheld          :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  visitor_id                     :string
#
class StateFileNyIntake < ApplicationRecord
  def primary
    Person.new(self, :primary)
  end

  class Person
    attr_reader :first_name
    attr_reader :last_name
    attr_reader :birth_date
    attr_reader :ssn

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @last_name = intake.primary_last_name
        @birth_date = intake.primary_dob
        @ssn = intake.primary_ssn
      end
    end
  end
end
