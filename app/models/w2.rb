# == Schema Information
#
# Table name: w2s
#
#  id                            :bigint           not null, primary key
#  creation_token                :string
#  employee                      :integer          default("unfilled"), not null
#  employee_city                 :string
#  employee_state                :string
#  employee_street_address       :string
#  employee_street_address2      :string
#  employee_zip_code             :string
#  employer_city                 :string
#  employer_ein                  :string
#  employer_name                 :string
#  employer_state                :string
#  employer_street_address       :string
#  employer_street_address2      :string
#  employer_zip_code             :string
#  federal_income_tax_withheld   :decimal(12, 2)
#  standard_or_non_standard_code :string
#  wages_amount                  :decimal(12, 2)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  intake_id                     :bigint
#
# Indexes
#
#  index_w2s_on_creation_token  (creation_token)
#  index_w2s_on_intake_id       (intake_id)
#
class W2 < ApplicationRecord
  belongs_to :intake

  encrypts :employee_ssn

  enum employee: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :employee

  before_validation do
    self.employee_ssn = self.employee_ssn.remove(/\D/) if employee_ssn_changed? && self.employee_ssn
  end

  def legal_first_name
    if employee_primary?
      intake.primary_first_name
    elsif employee_spouse?
      intake.spouse_first_name
    end
  end

  def legal_middle_initial
    if employee_primary?
      intake.primary_middle_initial
    elsif employee_spouse?
      intake.spouse_middle_initial
    end
  end

  def suffix
    if employee_primary?
      intake.primary_suffix
    elsif employee_spouse?
      intake.spouse_suffix
    end
  end

  def legal_last_name
    if employee_primary?
      intake.primary_last_name
    elsif employee_spouse?
      intake.spouse_last_name
    end
  end

  def employee_ssn
    if employee_primary?
      intake.primary_ssn
    elsif employee_spouse?
      intake.spouse_ssn
    end
  end

  def rounded_wages_amount
    wages_amount.round
  end

  def rounded_federal_income_tax_withheld
    federal_income_tax_withheld.round
  end
end
