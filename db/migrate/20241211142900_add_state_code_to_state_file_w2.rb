class AddStateCodeToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :state_code, :string
  end
end
