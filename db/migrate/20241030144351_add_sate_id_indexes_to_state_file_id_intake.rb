class AddSateIdIndexesToStateFileIdIntake < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :state_file_id_intakes, :primary_state_id_id, :bigint
    add_column :state_file_id_intakes, :spouse_state_id_id, :bigint
    add_index :state_file_id_intakes, :primary_state_id_id, name: 'index_state_file_id_intakes_on_primary_state_id_id', algorithm: :concurrently
    add_index :state_file_id_intakes, :spouse_state_id_id, name: 'index_state_file_id_intakes_on_spouse_state_id_id', algorithm: :concurrently
  end
end
