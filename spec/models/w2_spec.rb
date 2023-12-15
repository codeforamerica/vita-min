# == Schema Information
#
# Table name: w2s
#
#  id                                 :bigint           not null, primary key
#  box10_dependent_care_benefits      :decimal(12, 2)
#  box11_nonqualified_plans           :decimal(12, 2)
#  box12a_code                        :string
#  box12a_value                       :decimal(12, 2)
#  box12b_code                        :string
#  box12b_value                       :decimal(12, 2)
#  box12c_code                        :string
#  box12c_value                       :decimal(12, 2)
#  box12d_code                        :string
#  box12d_value                       :decimal(12, 2)
#  box13_retirement_plan              :integer          default("unfilled")
#  box13_statutory_employee           :integer          default("unfilled")
#  box13_third_party_sick_pay         :integer          default("unfilled")
#  box3_social_security_wages         :decimal(12, 2)
#  box4_social_security_tax_withheld  :decimal(12, 2)
#  box5_medicare_wages_and_tip_amount :decimal(12, 2)
#  box6_medicare_tax_withheld         :decimal(12, 2)
#  box7_social_security_tips_amount   :decimal(12, 2)
#  box8_allocated_tips                :decimal(12, 2)
#  box_d_control_number               :string
#  completed_at                       :datetime
#  creation_token                     :string
#  employee                           :integer          default("unfilled"), not null
#  employee_city                      :string
#  employee_ssn                       :string
#  employee_state                     :string
#  employee_street_address            :string
#  employee_zip_code                  :string
#  employer_city                      :string
#  employer_ein                       :string
#  employer_name                      :string
#  employer_state                     :string
#  employer_street_address            :string
#  employer_zip_code                  :string
#  federal_income_tax_withheld        :decimal(12, 2)
#  intake_type                        :string
#  wages_amount                       :decimal(12, 2)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint
#
# Indexes
#
#  index_w2s_on_creation_token  (creation_token)
#  index_w2s_on_intake_id       (intake_id)
#
require 'rails_helper'

describe 'W2' do
  let(:intake) { create(:ctc_intake, primary_first_name: 'ed', primary_last_name: 'ed', primary_middle_initial: 'a', primary_suffix: 'jr', spouse_first_name: 'stead', spouse_last_name: 'stead', spouse_middle_initial: 'b', spouse_suffix: 'sr',) }
  let(:w2) { create :w2, employee: employee, intake: intake }

  context 'the employee for the W2 has not be set' do
    let(:employee) { 'unfilled' }

    it 'is nil' do
      expect(w2.employee_first_name).to be_nil
      expect(w2.employee_last_name).to be_nil
      expect(w2.employee_middle_initial).to be_nil
      expect(w2.employee_suffix).to be_nil
      expect(w2.employee_ssn).to be_nil
    end
  end

  context 'the employee for the W2 is the primary filer' do
    let(:employee) { 'primary' }

    it 'delegates name and ssn to the primary fields on the intake' do
      expect(w2.employee_first_name).to eq intake.primary.first_name
      expect(w2.employee_last_name).to eq intake.primary.last_name
      expect(w2.employee_middle_initial).to eq intake.primary.middle_initial
      expect(w2.employee_suffix).to eq intake.primary.suffix
      expect(w2.employee_ssn).to eq intake.primary.ssn
    end
  end

  context 'the employee for the W2 is the spouse' do
    let(:employee) { 'spouse' }

    it 'delegates name and ssn to the spouse fields on the intake' do
      expect(w2.employee_first_name).to eq intake.spouse.first_name
      expect(w2.employee_last_name).to eq intake.spouse.last_name
      expect(w2.employee_middle_initial).to eq intake.spouse.middle_initial
      expect(w2.employee_suffix).to eq intake.spouse.suffix
      expect(w2.employee_ssn).to eq intake.spouse.ssn
    end
  end
end
