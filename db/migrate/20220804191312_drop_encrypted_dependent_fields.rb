class DropEncryptedDependentFields < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :dependents, :encrypted_ip_pin, :string
      remove_column :dependents, :encrypted_ip_pin_iv, :string
      remove_column :dependents, :encrypted_ssn, :string
      remove_column :dependents, :encrypted_ssn_iv, :string
    end
  end
end
