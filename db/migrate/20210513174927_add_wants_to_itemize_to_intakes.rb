class AddWantsToItemizeToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :wants_to_itemize, :integer, default: 0, null: false
  end
end
