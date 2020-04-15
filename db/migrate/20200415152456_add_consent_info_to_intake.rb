class AddConsentInfoToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_birth_date, :date
    add_column :intakes, :spouse_birth_date, :date
    add_column :intakes, :encrypted_primary_last_four_ssn, :string
    add_column :intakes, :encrypted_primary_last_four_ssn_iv, :string
    add_column :intakes, :encrypted_spouse_last_four_ssn, :string
    add_column :intakes, :encrypted_spouse_last_four_ssn_iv, :string
    add_column :intakes, :primary_full_legal_name, :string
    add_column :intakes, :spouse_full_legal_name, :string
  end
end
