class AddColumnsToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :employer_name, :string
    add_column :state_file_w2s, :employee_name, :string
    add_column :state_file_w2s, :employee_ssn, :string
    add_column :state_file_w2s, :employer_ein, :string
    add_column :state_file_w2s, :employer_name_control_txt, :string
    add_column :state_file_w2s, :employer_street_address, :string
    add_column :state_file_w2s, :employer_city, :string
    add_column :state_file_w2s, :employer_state, :string
    add_column :state_file_w2s, :employer_zip, :string
    add_column :state_file_w2s, :employee_address_line_1, :string
    add_column :state_file_w2s, :employee_address_line_2, :string
    add_column :state_file_w2s, :employee_city, :string
    add_column :state_file_w2s, :employee_state, :string
    add_column :state_file_w2s, :employee_zip, :string
    add_column :state_file_w2s, :wages_amount, :string
    add_column :state_file_w2s, :withholding_amount, :string
    add_column :state_file_w2s, :social_security_wages_amount, :string
    add_column :state_file_w2s, :social_security_tax_amount, :string
    add_column :state_file_w2s, :medicare_wages_and_tips_amount, :string
    add_column :state_file_w2s, :medicare_tax_withheld_amount, :string
    add_column :state_file_w2s, :other_deductions_benefits_desc, :string
    add_column :state_file_w2s, :other_deductions_benefits_amount, :string
    add_column :state_file_w2s, :standard_or_nonstandard_code, :string

    # hmmmmm
    # SocialSecurityTipsAmt
    # AllocatedTipsAmt
    # DependentCareBenefitsAmt
    # NonqualifiedPlansAmt
  end
end
