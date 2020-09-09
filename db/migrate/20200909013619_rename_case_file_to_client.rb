class RenameCaseFileToClient < ActiveRecord::Migration[6.0]
  def change
    rename_table :case_files, :clients
    rename_column :incoming_text_messages, :case_file_id, :client_id
    rename_column :outgoing_text_messages, :case_file_id, :client_id
  end
end
