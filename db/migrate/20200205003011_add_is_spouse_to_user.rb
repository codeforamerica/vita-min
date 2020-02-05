class AddIsSpouseToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_spouse, :boolean, default: false
  end
end
