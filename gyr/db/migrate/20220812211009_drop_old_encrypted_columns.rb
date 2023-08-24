class DropOldEncryptedColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :intakes, :encrypted_primary_last_four_ssn }
    safety_assured { remove_column :intakes, :encrypted_primary_last_four_ssn_iv }
    safety_assured { remove_column :intakes, :encrypted_spouse_last_four_ssn }
    safety_assured { remove_column :intakes, :encrypted_spouse_last_four_ssn_iv }
    safety_assured { remove_column :intakes, :encrypted_spouse_ssn_iv }
    safety_assured { remove_column :intakes, :encrypted_spouse_ssn }
    safety_assured { remove_column :intakes, :encrypted_primary_ssn }
    safety_assured { remove_column :intakes, :encrypted_primary_ssn_iv }
    safety_assured { remove_column :intakes, :encrypted_bank_name }
    safety_assured { remove_column :intakes, :encrypted_bank_name_iv }
    safety_assured { remove_column :intakes, :encrypted_bank_routing_number }
    safety_assured { remove_column :intakes, :encrypted_bank_routing_number_iv }
    safety_assured { remove_column :intakes, :encrypted_primary_ip_pin }
    safety_assured { remove_column :intakes, :encrypted_spouse_ip_pin }
    safety_assured { remove_column :intakes, :encrypted_primary_ip_pin_iv }
    safety_assured { remove_column :intakes, :encrypted_spouse_ip_pin_iv }
    safety_assured { remove_column :intakes, :encrypted_bank_account_number }
    safety_assured { remove_column :intakes, :encrypted_bank_account_number_iv }
    safety_assured { remove_column :intakes, :encrypted_primary_signature_pin }
    safety_assured { remove_column :intakes, :encrypted_spouse_signature_pin }
    safety_assured { remove_column :intakes, :encrypted_spouse_signature_pin_iv }
    safety_assured { remove_column :intakes, :encrypted_primary_signature_pin_iv }

    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_last_four_ssn }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_last_four_ssn_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_last_four_ssn }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_last_four_ssn_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_ssn_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_ssn }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_ssn }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_ssn_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_bank_name }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_bank_name_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_bank_routing_number }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_bank_routing_number_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_ip_pin }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_ip_pin }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_ip_pin_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_ip_pin_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_bank_account_number }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_bank_account_number_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_signature_pin }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_signature_pin }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_spouse_signature_pin_iv }
    safety_assured { remove_column :archived_intakes_2021, :encrypted_primary_signature_pin_iv }

    safety_assured { remove_column :archived_dependents_2021, :encrypted_ssn_iv }
    safety_assured { remove_column :archived_dependents_2021, :encrypted_ssn }
    safety_assured { remove_column :archived_dependents_2021, :encrypted_ip_pin_iv }
    safety_assured { remove_column :archived_dependents_2021, :encrypted_ip_pin }

    safety_assured { remove_column :archived_bank_accounts_2021, :encrypted_bank_name }
    safety_assured { remove_column :archived_bank_accounts_2021, :encrypted_bank_name_iv }
    safety_assured { remove_column :archived_bank_accounts_2021, :encrypted_account_number }
    safety_assured { remove_column :archived_bank_accounts_2021, :encrypted_account_number_iv }
    safety_assured { remove_column :archived_bank_accounts_2021, :encrypted_routing_number }
    safety_assured { remove_column :archived_bank_accounts_2021, :encrypted_routing_number_iv }

  end
end
