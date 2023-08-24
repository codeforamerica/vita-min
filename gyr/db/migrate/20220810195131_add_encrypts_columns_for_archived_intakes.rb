class AddEncryptsColumnsForArchivedIntakes < ActiveRecord::Migration[7.0]
  def change
      add_column :archived_intakes_2021, :primary_last_four_ssn, :text
      add_column :archived_intakes_2021, :spouse_last_four_ssn, :text
      add_column :archived_intakes_2021, :primary_ssn, :text
      add_column :archived_intakes_2021, :spouse_ssn, :text
      add_column :archived_intakes_2021, :bank_account_number, :text
      add_column :archived_intakes_2021, :bank_name, :string
      add_column :archived_intakes_2021, :bank_routing_number, :string
      add_column :archived_intakes_2021, :primary_ip_pin, :text
      add_column :archived_intakes_2021, :spouse_ip_pin, :text
      add_column :archived_intakes_2021, :primary_signature_pin, :text
      add_column :archived_intakes_2021, :spouse_signature_pin, :text
  end
end
