class CreateStateFileIdIntakes < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_id_intakes do |t|
      # personal info
      t.string :primary_first_name
      t.string :primary_last_name
      t.date :primary_birth_date

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
      t.integer :contact_preference, default: 0, null: false
      t.jsonb :message_tracker, default: {}
      t.boolean :unsubscribed_from_email, default: false, null: false

      # devise
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :last_sign_in_ip
      t.inet :current_sign_in_ip
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at

      # baseline flow
      t.string :current_step
      t.integer :eligibility_lived_in_state, default: 0, null: false
      t.integer :eligibility_out_of_state_income, default: 0, null: false
      t.integer :consented_to_terms_and_conditions, default: 0, null: false
      t.integer :primary_esigned, default: 0, null: false
      t.datetime :primary_esigned_at
      t.integer :spouse_esigned, default: 0, null: false
      t.datetime :spouse_esigned_at
      t.string :account_number
      t.integer :account_type, default: 0, null: false
      t.integer :payment_or_deposit_type, default: 0, null: false
      t.integer :routing_number
      t.string :bank_name
      t.integer :withdraw_amount
      t.date :date_electronic_withdrawal

      # federal fields
      t.text :raw_direct_file_data
      t.jsonb :raw_direct_file_intake_data
      t.datetime :df_data_imported_at
      t.datetime :df_data_import_failed_at
      t.string :federal_submission_id
      t.string :federal_return_status
      t.string :hashed_ssn # also add an index (algorithm: :concurrently)

      t.index ["email_address"], name: "index_state_file_id_intakes_on_email_address"
      t.index ["hashed_ssn"], name: "index_state_file_id_intakes_on_hashed_ssn"

      t.timestamps
    end
  end
end
