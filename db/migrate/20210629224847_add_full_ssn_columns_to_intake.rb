class AddFullSsnColumnsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :encrypted_primary_ssn, :string
    add_column :intakes, :encrypted_primary_ssn_iv, :string
    add_column :intakes, :encrypted_spouse_ssn, :string
    add_column :intakes, :encrypted_spouse_ssn_iv, :string
  end
end
