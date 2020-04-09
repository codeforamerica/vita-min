class AddAnonymousToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :anonymous, :boolean, default: false, null: false
  end
end
