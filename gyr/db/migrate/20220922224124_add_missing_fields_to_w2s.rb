class AddMissingFieldsToW2s < ActiveRecord::Migration[7.0]
  def change
    add_column :w2s, :box3_social_security_wages, :decimal, precision: 12, scale: 2
    add_column :w2s, :box4_social_security_tax_withheld, :decimal, precision: 12, scale: 2
    add_column :w2s, :box5_medicare_wages_and_tip_amount, :decimal, precision: 12, scale: 2
    add_column :w2s, :box6_medicare_tax_withheld, :decimal, precision: 12, scale: 2
    add_column :w2s, :box7_social_security_tips_amount, :decimal, precision: 12, scale: 2
    add_column :w2s, :box8_allocated_tips, :decimal, precision: 12, scale: 2
    add_column :w2s, :box10_dependent_care_benefits, :decimal, precision: 12, scale: 2
    add_column :w2s, :box11_nonqualified_plans, :decimal, precision: 12, scale: 2
    add_column :w2s, :box12a_code, :string
    add_column :w2s, :box12a_value, :decimal, precision: 12, scale: 2
    add_column :w2s, :box12b_code, :string
    add_column :w2s, :box12b_value, :decimal, precision: 12, scale: 2
    add_column :w2s, :box12c_code, :string
    add_column :w2s, :box12c_value, :decimal, precision: 12, scale: 2
    add_column :w2s, :box12d_code, :string
    add_column :w2s, :box12d_value, :decimal, precision: 12, scale: 2
    add_column :w2s, :box13_statutory_employee, :integer, default: 0
    add_column :w2s, :box13_retirement_plan, :integer, default: 0
    add_column :w2s, :box13_third_party_sick_pay, :integer, default: 0
    add_column :w2s, :box_d_control_number, :string
  end
end
