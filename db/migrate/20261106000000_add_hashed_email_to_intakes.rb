class AddHashedEmailToIntakes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :intakes, :hashed_email, :string
    add_column :state_file_az_intakes, :hashed_email, :string
    add_column :state_file_id_intakes, :hashed_email, :string
    add_column :state_file_md_intakes, :hashed_email, :string
    add_column :state_file_nc_intakes, :hashed_email, :string
    add_column :state_file_nj_intakes, :hashed_email, :string
    add_column :state_file_ny_intakes, :hashed_email, :string
    add_column :state_file_archived_intakes, :hashed_email, :string

    add_index :intakes, :hashed_email, algorithm: :concurrently
    add_index :state_file_az_intakes, :hashed_email, algorithm: :concurrently
    add_index :state_file_id_intakes, :hashed_email, algorithm: :concurrently
    add_index :state_file_md_intakes, :hashed_email, algorithm: :concurrently
    add_index :state_file_nc_intakes, :hashed_email, algorithm: :concurrently
    add_index :state_file_nj_intakes, :hashed_email, algorithm: :concurrently
    add_index :state_file_ny_intakes, :hashed_email, algorithm: :concurrently
  end
end
