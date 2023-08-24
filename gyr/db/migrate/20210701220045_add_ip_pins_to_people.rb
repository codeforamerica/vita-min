class AddIpPinsToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_ip_pin, :integer
    add_column :intakes, :spouse_ip_pin, :integer
    add_column :dependents, :ip_pin, :integer
  end
end
