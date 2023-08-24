class AddDataToSystemNote < ActiveRecord::Migration[6.0]
  def change
    add_column :system_notes, :data, :jsonb
  end
end
