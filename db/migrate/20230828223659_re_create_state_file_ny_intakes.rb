class ReCreateStateFileNyIntakes < ActiveRecord::Migration[7.0]
  def change
    drop_table :state_file_ny_intakes
    create_table :state_file_ny_intakes do |t|
      t.integer :tax_return_year
      t.string :visitor_id
      t.string :current_step
      t.string :primary_first_name
      t.string :primary_middle_initial
      t.string :primary_last_name
      t.date :primary_dob
      t.string :primary_ssn
      t.string :spouse_first_name
      t.string :spouse_middle_initial
      t.string :spouse_last_name
      t.date :spouse_dob
      t.string :spouse_ssn
      t.string :mailing_street
      t.string :mailing_apartment
      t.string :residence_county
      t.string :mailing_city
      t.string :mailing_state
      t.string :mailing_zip
      t.string :mailing_country
      t.string :school_district
      t.integer :school_district_number
      t.string :permanent_street
      t.string :permanent_apartment
      t.string :permanent_city
      t.string :permanent_zip
      t.integer :filing_status
      t.integer :claimed_as_dep
      t.integer :nyc_resident_e
      t.integer :fed_wages
      t.integer :fed_taxable_income
      t.integer :fed_unemployment
      t.integer :fed_taxable_ssb
      t.string :total_fed_adjustments_identify
      t.integer :total_fed_adjustments
      t.integer :ny_414h_retirement
      t.integer :ny_other_additions
      t.integer :ny_taxable_ssb
      t.integer :sales_use_tax
      t.integer :total_ny_tax_withheld
      t.integer :refund_choice
      t.integer :amount_owed_pay_electronically
      t.integer :account_type
      t.string :routing_number
      t.string :account_number
      t.date :date_electronic_withdrawal
      t.integer :amount_electronic_withdrawal
      t.string :primary_signature
      t.string :primary_occupation
      t.string :spouse_signature
      t.string :spouse_occupation
      t.string :phone_daytime_area_code
      t.string :phone_daytime
      t.string :primary_email
      
      t.timestamps
    end
  end
end
