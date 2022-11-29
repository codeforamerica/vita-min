class AddLast13614cUpdateAtToClient < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :last_13614c_update_at, :timestamp
  end
end
