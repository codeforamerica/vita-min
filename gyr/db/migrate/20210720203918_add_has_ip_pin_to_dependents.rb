class AddHasIpPinToDependents < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :has_ip_pin, :integer, default: 0, null: false
  end
end
