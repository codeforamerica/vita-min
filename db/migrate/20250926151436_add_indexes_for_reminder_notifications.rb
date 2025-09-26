class AddIndexesForReminderNotifications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    state_tables = %i[
      state_file_az_intakes
      state_file_md_intakes
      state_file_nj_intakes
      state_file_id_intakes
      state_file_nc_intakes
    ]

    state_tables.each do |table|
      add_index table, :created_at, algorithm: :concurrently

      add_index table, :id,
                where: "(phone_number IS NOT NULL AND phone_number_verified_at IS NOT NULL)",
                name: "index_#{table}_phone_verified",
                algorithm: :concurrently

      add_index table, :id,
                where: "(email_address IS NOT NULL AND email_address_verified_at IS NOT NULL)",
                name: "index_#{table}_email_verified",
                algorithm: :concurrently
    end
  end
end
