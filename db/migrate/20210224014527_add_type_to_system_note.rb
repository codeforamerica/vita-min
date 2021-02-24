class AddTypeToSystemNote < ActiveRecord::Migration[6.0]
  def change
    add_column :system_notes, :type, :string
  end
end
