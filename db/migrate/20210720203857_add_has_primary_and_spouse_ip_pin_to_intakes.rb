class AddHasPrimaryAndSpouseIpPinToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :has_primary_ip_pin, :integer, default: 0, null: false
    add_column :intakes, :has_spouse_ip_pin, :integer, default: 0, null: false
  end
end
