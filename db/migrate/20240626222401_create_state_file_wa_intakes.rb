class CreateStateFileWaIntakes < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_wa_intakes do |t|
      t.string :primary_first_name
      t.string :primary_last_name
      t.integer :tax_return_year
      t.string :street_address
      t.string :city
      t.string :zip_code
      t.string :ssn
      t.string :source
      t.citext :email_address
      t.string :phone_number
      t.datetime :email_address_verified_at
      t.datetime :phone_number_verified_at
      t.string :referrer
      t.date :birth_date
      t.string :current_step
      t.string :visitor_id
      t.integer :contact_preference, default: 0, null: false
      t.integer :eligibility_lived_in_state, default: 0, null: false
      t.integer :eligibility_out_of_state_income, default: 0, null: false
      t.integer :primary_esigned, default: 0, null: false
      t.integer :spouse_esigned, default: 0, null: false
      t.integer :account_type, default: 0, null: false
      t.integer :payment_or_deposit_type, default: 0, null: false
      t.integer :consented_to_terms_and_conditions, default: 0, null: false
      t.text :raw_direct_file_data
      t.string :locale, default: 'en'

      # trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :last_sign_in_ip
      t.inet :current_sign_in_ip
      # lockable
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at

      t.timestamps
    end
  end
end
