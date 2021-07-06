class AddEncryptionToIpPins < ActiveRecord::Migration[6.0]
  def change
    remove_column :intakes, :primary_ip_pin, :integer
    remove_column :intakes, :spouse_ip_pin, :integer
    remove_column :dependents, :ip_pin, :integer

    add_column :intakes, :encrypted_primary_ip_pin, :string
    add_column :intakes, :encrypted_spouse_ip_pin, :string
    add_column :dependents, :encrypted_ip_pin, :string

    add_column :intakes, :encrypted_primary_ip_pin_iv, :string
    add_column :intakes, :encrypted_spouse_ip_pin_iv, :string
    add_column :dependents, :encrypted_ip_pin_iv, :string
  end
end
