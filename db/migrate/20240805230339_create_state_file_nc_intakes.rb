class CreateStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_nc_intakes do |t|
      # misc
      t.integer :tax_return_year
      t.integer :filing_status
      t.string :current_step
      t.text :raw_direct_file_data

      # personal info
      t.string :primary_first_name
      t.string :primary_last_name
      t.date :primary_birth_date
      t.string :ssn
      t.string :street_address
      t.string :city
      t.string :zip_code

      # browser info
      t.string :source
      t.string :referrer
      t.string :locale, default: 'en'
      t.string :visitor_id

      # contact info
      t.citext :email_address
      t.string :phone_number
      t.datetime :email_address_verified_at
      t.datetime :phone_number_verified_at

      # enums
      t.integer :contact_preference, default: 0, null: false
      t.integer :eligibility_lived_in_state, default: 0, null: false
      t.integer :eligibility_out_of_state_income, default: 0, null: false
      t.integer :primary_esigned, default: 0, null: false
      t.integer :spouse_esigned, default: 0, null: false
      t.integer :account_type, default: 0, null: false
      t.integer :payment_or_deposit_type, default: 0, null: false
      t.integer :consented_to_terms_and_conditions, default: 0, null: false

      # devise
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :last_sign_in_ip
      t.inet :current_sign_in_ip
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at

      t.timestamps
    end
  end
end
