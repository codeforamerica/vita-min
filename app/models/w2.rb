# == Schema Information
#
# Table name: w2s
#
#  id                            :bigint           not null, primary key
#  completed_at                  :datetime
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

  scope :completed, -> { where.not(completed_at: nil) }

  enum employee: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :employee

  delegate :first_name, :middle_initial, :suffix, :last_name, :ssn, to: :employee_obj, allow_nil: true, prefix: :employee

  def employee_obj
    if employee_primary?
      intake.primary
    elsif employee_spouse?
      intake.spouse
    end
  end

  def rounded_wages_amount
    wages_amount.round
  end

  def rounded_federal_income_tax_withheld
    federal_income_tax_withheld.round
  end
end
