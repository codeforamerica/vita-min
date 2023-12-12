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
class W2 < ApplicationRecord
  BOX12_OPTIONS = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "Y", "Z", "AA", "BB", "DD", "EE", "FF", "GG", "HH"]
  BOX12_OFFBOARD_CODES = %w(A B K L M N R V W Z)

  belongs_to :intake, :polymorphic => true
  has_one :w2_state_fields_group, dependent: :destroy
  has_many :w2_box14, dependent: :destroy

  accepts_nested_attributes_for :w2_state_fields_group, update_only: true
  accepts_nested_attributes_for :w2_box14, update_only: true

  scope :completed, -> { where.not(completed_at: nil) }

  enum employee: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :employee
  enum box13_statutory_employee: { unfilled: 0, yes: 1, no: 2 }, _prefix: :box13_statutory_employee
  enum box13_retirement_plan: { unfilled: 0, yes: 1, no: 2 }, _prefix: :box13_retirement_plan
  enum box13_third_party_sick_pay: { unfilled: 0, yes: 1, no: 2 }, _prefix: :box13_third_party_sick_pay

  delegate :first_name, :middle_initial, :suffix, :last_name, :ssn, to: :employee_obj, allow_nil: true, prefix: :employee

  def employee_obj
    if employee_primary?
      intake.primary
    elsif employee_spouse?
      intake.spouse
    end
  end

end
