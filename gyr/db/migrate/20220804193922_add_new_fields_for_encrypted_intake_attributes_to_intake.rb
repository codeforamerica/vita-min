class AddNewFieldsForEncryptedIntakeAttributesToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :primary_last_four_ssn, :text
    add_column :intakes, :spouse_last_four_ssn, :text
    add_column :intakes, :primary_ssn, :text
    add_column :intakes, :spouse_ssn, :text
    add_column :intakes, :bank_account_number, :text
    add_column :intakes, :bank_name, :string
    add_column :intakes, :bank_routing_number, :string
    add_column :intakes, :primary_ip_pin, :text
    add_column :intakes, :spouse_ip_pin, :text
    add_column :intakes, :primary_signature_pin, :text
    add_column :intakes, :spouse_signature_pin, :text
  end
end
