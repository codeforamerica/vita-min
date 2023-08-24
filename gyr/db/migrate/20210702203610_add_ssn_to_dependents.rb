class AddSsnToDependents < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :encrypted_ssn, :string
    add_column :dependents, :encrypted_ssn_iv, :string
  end
end
