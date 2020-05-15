class AddAlreadyFiledToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :already_filed, :integer, default: 0, null: false
  end
end
