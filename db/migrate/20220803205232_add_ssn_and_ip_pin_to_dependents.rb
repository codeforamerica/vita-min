class AddSsnAndIpPinToDependents < ActiveRecord::Migration[7.0]
  def change
    add_column :dependents, :ssn, :text
    add_column :dependents, :ip_pin, :text
  end
end
